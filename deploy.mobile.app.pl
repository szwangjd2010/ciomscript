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

our $ciomUtil = new CiomUtil(1);
our $AppVcaHome = "$ENV{CIOM_VCA_HOME}/$version/pre/$cloudId/$appName";
our $ApppkgPath = "$ENV{JENKINS_HOME}/jobs/$ENV{JOB_NAME}/builds/$ENV{BUILD_NUMBER}/app";
our $Pms = {};
our $CiomData = json_file_to_perl("$AppVcaHome/ciom.json");

my $ShellStreamedit = "_streamedit.ciom";
my $OldPwd = getcwd();
my $orgCodesWhichNeedToBuild = [];

sub getAppMainModuleName() {
	return $CiomData->{scm}->{repos}->[0]->{name};
}

sub getBuildLogFile() {
	return "$ENV{JENKINS_HOME}/jobs/$ENV{JOB_NAME}/builds/$ENV{BUILD_NUMBER}/log";
}

sub doPlatformDependencyInjection() {
	require "$cloudId.special.pl";	
}

sub enterWorkspace() {
	my $appWorkspace = "$ENV{WORKSPACE}/$appName" || "/var/lib/jenkins/workspace/mobile.$cloudId-eschool/$appName";
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
	my $cmdRmUnversionedTpl = "$cmdSvnPrefix status %s | grep '^?' | awk '{print \$2}' | xargs -I{} rm -rf '{}'";
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
	my $CmdStreameditTpl = "perl -CSDL %s-i -pE 's|%s|%s|mg' %s";
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

sub replacePmsInShellStreamedit() {
	my $nCiompmCnt = $ciomUtil->execWithReturn("grep -c '<ciompm>' $ShellStreamedit");
	if ($nCiompmCnt == 0) {
		return;
	}

	for my $key (keys %{$Pms}) {
		$nCiompmCnt = $ciomUtil->execWithReturn("grep -c '<ciompm>$key</ciompm>' $ShellStreamedit");
		if ($nCiompmCnt == 0) {
			next;
		}

		my $v = $Pms->{$key};
		$ciomUtil->log("\n\ninstancing $key ...");
		$ciomUtil->exec("cat $ShellStreamedit");
		$ciomUtil->exec("perl -CSDL -i -pE 's|<ciompm>$key</ciompm>|$v|mg' $ShellStreamedit");
	}	
}

sub streamedit($) {
	my $items = $_[0];
	generateStreameditFile($items);
	replacePmsInShellStreamedit();
	
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

sub outputApppkgUrl() {
	my $url = "$ENV{BUILD_URL}/app";
	$url =~ s|:8080||;
	$url =~ s|(/\d+/)|/builds/lastStableBuild|;
	$url = $ciomUtil->prettyPath($url);
	$ciomUtil->log("\n\nbuild out packages url:");
	$ciomUtil->log($url);
	$ciomUtil->log("\n\n");
}

sub iterateOrgsAndBuildEligibles() {
	my $cnt = $#{$orgCodesWhichNeedToBuild} + 1;
	for (my $i = 0; $i < $cnt; $i++) {
		my $code = $orgCodesWhichNeedToBuild->[$i];
		revertCode();
		replaceOrgCustomizedFiles($code);
		streameditConfs4AllOrgs();
		streameditConfs4Org($code);
		build();
		moveApppkgFile($code);
		cleanAfterOrgBuild();
	}	
}

sub getOrgCodesWhichNeedToBuild() {
	if ($orgCodes eq '*') {
		my @orgsKeys = keys %{$CiomData->{orgs}};
		$orgCodesWhichNeedToBuild = \@orgsKeys;
		return;
	}

	for my $code (keys %{$CiomData->{orgs}}) {
		my $re = '(^|,)' . $code . '($|,)';
		if ($orgCodes =~ m/$re/) {
			push(@{$orgCodesWhichNeedToBuild}, $code);
		}
	}
}

sub validateInputOrgCodes() {
	return $#{$orgCodesWhichNeedToBuild} >= 0;
}

sub outputOrgCodesWhichNeedToBuild() {
	$ciomUtil->log(Dumper($orgCodesWhichNeedToBuild));
}

sub main() {
	getOrgCodesWhichNeedToBuild();
	if (!validateInputOrgCodes()) {
		$ciomUtil->log("\n\nbuild error: org code \"$orgCodes\" does not exists!\n\n");
		return 1;
	}
	outputOrgCodesWhichNeedToBuild();
	
	doPlatformDependencyInjection();
	enterWorkspace();
	makeApppkgDirectory();
	updateCode(0);
	fillPms();
	extraPreAction();
	iterateOrgsAndBuildEligibles();
	extraPostAction();
	outputApppkgUrl();
	leaveWorkspace();

	return getBuildError();
}

exit main();
