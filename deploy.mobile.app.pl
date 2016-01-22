#!/usr/bin/perl -W
# 
#
use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use English;
use Data::Dumper;
use Cwd;
use CiomUtil;
use JSON::Parse 'json_file_to_perl';
use String::Escape 'escape';
use open ":encoding(utf8)";
use open IN => ":encoding(utf8)", OUT => ":utf8";
use IO::Handle;
STDOUT->autoflush(1);

our $version = $ARGV[0];
our $cloudId = $ARGV[1];
our $appName = $ARGV[2];
our $orgCodes = $ARGV[3] || '*';

our $doPublish = $ENV{UploadPackage} || 'NO';

our $ciomUtil = new CiomUtil(1);
our $AppVcaHome = "$ENV{CIOM_VCA_HOME}/$version/pre/$cloudId/$appName";
our $ApppkgPath = "$ENV{JENKINS_HOME}/jobs/$ENV{JOB_NAME}/builds/$ENV{BUILD_NUMBER}/app";
our $DynamicParams = {};
our $CiomData = json_file_to_perl("$AppVcaHome/ciom.json");

my $ShellStreamedit = "_streamedit.ciom";
my $OldPwd = getcwd();
my $NeedToBuildOrgCodes = [];

sub getBuildLogFile() {
	return "$ENV{JENKINS_HOME}/jobs/$ENV{JOB_NAME}/builds/$ENV{BUILD_NUMBER}/log";
}

sub injectPlatformDependency() {
	require "$ENV{CIOM_SCRIPT_HOME}/$cloudId.special.pl";	
}

sub enterWorkspace() {
	my $appWorkspace = "$ENV{WORKSPACE}/$appName";
	if (! -d $appWorkspace) {
		$ciomUtil->exec("mkdir -p $appWorkspace");
	}

	chdir($appWorkspace);
}

sub leaveWorkspace() {
	chdir($OldPwd);
}

sub makeApppkgDirectory() {
	$ciomUtil->exec("mkdir $ApppkgPath");
}

#platform special#

sub updateCode($) {
	my $doRevert = shift || 0;
	my $repos = $CiomData->{scm}->{repos};
	my $username = $CiomData->{scm}->{username};
	my $password = $CiomData->{scm}->{password};
	my $cnt = $#{$repos} + 1;

	my $cmdSvnPrefix = "svn --non-interactive --username $username --password '$password'";
	my $cmdRmUnversionedTpl = "$cmdSvnPrefix status %s | grep -P '^\?' | awk '{print \$2}' | xargs -I{} rm -rf '{}'";
	for (my $i = 0; $i < $cnt; $i++) {
		my $name = $repos->[$i]->{name};
		my $url = $repos->[$i]->{url};

		if ($doRevert == 1) {
			$ciomUtil->execNotLogCmd(sprintf($cmdRmUnversionedTpl, $name));
			$ciomUtil->exec("$cmdSvnPrefix revert -R $name");
		} else {
			if (! -d $name) {
				$ciomUtil->exec("$cmdSvnPrefix co $url $name");
			} else {
				$ciomUtil->execNotLogCmd(sprintf($cmdRmUnversionedTpl, $name));
				$ciomUtil->exec("$cmdSvnPrefix revert -R $name");
				$ciomUtil->exec("$cmdSvnPrefix update $name");
			}			
		}
	}
}

sub revertCode() {
	updateCode(1);
}

sub replaceOrgCustomizedFiles($) {
	my $code = $_[0];
	my $orgCustomizedHome = "$AppVcaHome/resource/$code";
	$ciomUtil->exec("/bin/cp -rf $orgCustomizedHome/* ./");
}

sub generateStreameditFile($) {
	my $items = $_[0];

	my $cmds = "";
	my $CmdStreameditTpl = "perl -CSDL %s-i -pE 's|%s|%s|mg' '%s'";
	for my $file (keys %{$items}) {
		my $v = $items->{$file};
		my $cnt = $#{$v} + 1;
		
		for (my $i = 0; $i < $cnt; $i++) {
			my $lineMode = defined($v->[$i]->{single}) ? '-0 ' : '';
			$cmds .= sprintf($CmdStreameditTpl,
				$lineMode,
				$v->[$i]->{re},
				$v->[$i]->{to},
				$file
			);
			$cmds .= "\n";
		}
	}

	$ciomUtil->writeToFile("$ShellStreamedit", $cmds);
}

sub constructDynamicParamsMap() {
	while ( my ($key, $value) = each(%ENV) ) {
		if ($key =~ m/^CIOMPM_(\w+)$/) {
			$DynamicParams->{$1} = $value;
		}
    }
}

sub instantiateDynamicParamsInStreameditFile() {
	my $nCiompmCnt = $ciomUtil->execWithReturn("grep -c '<ciompm>' '$ShellStreamedit'");
	if ($nCiompmCnt == 0) {
		return;
	}

	for my $key (keys %{$DynamicParams}) {
		my $keyPlaceholder = "<ciompm>$key</ciompm>";
		$nCiompmCnt = $ciomUtil->execWithReturn("grep -c '$keyPlaceholder' '$ShellStreamedit'");
		if ($nCiompmCnt == 0) {
			next;
		}

		my $v = $DynamicParams->{$key};
		$ciomUtil->log("instancing $keyPlaceholder ...");
		$ciomUtil->exec("perl -CSDL -i -pE 's|$keyPlaceholder|$v|mg' '$ShellStreamedit'");
		$ciomUtil->exec("cat '$ShellStreamedit'");
	}	
}

sub instantiateDynamicParamsInStr($) {
	my $str = shift;
	if (index($str, '<ciompm>') == -1)  {
		return $str;
	}

	for my $key (keys %{$DynamicParams}) {
		my $keyPlaceholder = "<ciompm>$key</ciompm>";
		if (index($str, $keyPlaceholder) == -1)  {
			next;
		}		

		my $v = $DynamicParams->{$key};
		$ciomUtil->log("instancing $keyPlaceholder in $str...");
		$str =~ s|$keyPlaceholder|$v|g;
		$ciomUtil->log($str);
	}

	return $str;	
}

sub getAppFinalPkgName($) {
	my $code = $_[0];
	my $pkgName = $CiomData->{orgs}->{$code}->{pkgName} || $CiomData->{pkgName};
	$pkgName =~ s|#code#|$code|;
	$pkgName = instantiateDynamicParamsInStr($pkgName);

	my $appExtName = $cloudId eq 'ios' ? 'ipa' : 'apk';
	return "${pkgName}.${appExtName}";
}

sub streamedit($) {
	my $items = $_[0];
	generateStreameditFile($items);
	instantiateDynamicParamsInStreameditFile();
	
	$ciomUtil->exec("bash $ShellStreamedit");
	$ciomUtil->exec("cat $ShellStreamedit");
	$ciomUtil->exec("cat $ShellStreamedit >> _streamedit.ciom.all");
}

sub streameditConfs4Org($) {
	my $code = $_[0];
	my $streameditItems = $CiomData->{orgs}->{$code}->{streameditItems};
	$ciomUtil->exec("echo '$code' >> _streamedit.ciom.all");
	streamedit($streameditItems);
}

sub streameditConfs4AllOrgs() {
	my $streameditItems = $CiomData->{streameditItems};
	$ciomUtil->exec("\n\n\necho '$ENV{BUILD_NUMBER} - $orgCodes' >> _streamedit.ciom.all");
	$ciomUtil->exec("echo ciom.global >> _streamedit.ciom.all");
	streamedit($streameditItems);
}

sub logApppkgUrl() {
	my $url = "$ENV{BUILD_URL}/app";
	$url =~ s|:8080||;
	$url =~ s|(/\d+/)|/builds/lastStableBuild|;
	$url = $ciomUtil->prettyPath($url);
	$ciomUtil->log("\n\nbuild out packages url:");
	$ciomUtil->log($url);
	$ciomUtil->log("\n\n");
}

sub buildEligibleOrgs() {
	my $cnt = $#{$NeedToBuildOrgCodes} + 1;
	for (my $i = 0; $i < $cnt; $i++) {
		my $code = $NeedToBuildOrgCodes->[$i];
		revertCode();
		replaceOrgCustomizedFiles($code);
		streameditConfs4AllOrgs();
		streameditConfs4Org($code);
		build();
		moveApppkgFile($code);
		cleanAfterOrgBuild();
	}	
}

sub getNeedToBuildOrgCodes() {
	if ($orgCodes eq '*') {
		my @orgsKeys = keys %{$CiomData->{orgs}};
		$NeedToBuildOrgCodes = \@orgsKeys;
		return;
	}

	for my $code (keys %{$CiomData->{orgs}}) {
		my $re = '(^|,)' . $code . '($|,)';
		if ($orgCodes =~ m/$re/) {
			push(@{$NeedToBuildOrgCodes}, $code);
		}
	}
}

sub validateInputOrgCodes() {
	getNeedToBuildOrgCodes();
	logNeedToBuildOrgCodes();
	return $#{$NeedToBuildOrgCodes} >= 0;
}

sub logNeedToBuildOrgCodes() {
	$ciomUtil->log(Dumper($NeedToBuildOrgCodes));
}

sub uploadPkgs() {
	my $publishto = $CiomData->{publishto};
	if (!defined($publishto)) {
		return;
	}

	my $ip = $publishto->{ip};
	my $port = $publishto->{port} || 22;
	my $user = $publishto->{user} || 'ciom';
	my $path = $publishto->{path};
	if (!defined($ip) || !defined($path)) {
		return;
	}	
	
	$ciomUtil->exec("scp -r -P $port $ApppkgPath/* $user\@$ip:/$path/");
}

sub main() {
	if (!validateInputOrgCodes()) {
		$ciomUtil->log("\n\nbuild error: org code \"$orgCodes\" does not exists!\n\n");
		return 1;
	}
	
	enterWorkspace();
	injectPlatformDependency();
	constructDynamicParamsMap();
	makeApppkgDirectory();
	updateCode(0);
	globalPreAction();
	buildEligibleOrgs();
	globalPostAction();
	logApppkgUrl();

	if ($doPublish eq 'YES') {
		uploadPkgs();
	}

	leaveWorkspace();

	return getBuildError();
}

exit main();
