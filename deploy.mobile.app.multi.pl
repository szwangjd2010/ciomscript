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
use POSIX qw(strftime);
STDOUT->autoflush(1);

sub uploadOrgPkgs($);

our $executorIdx = $ARGV[0];
our $ciomUtil = new CiomUtil(1);

our $ApppkgPath = "$ENV{JENKINS_HOME}/jobs/$ENV{JOB_NAME}/builds/$ENV{BUILD_NUMBER}/app";
our $DistInfo = json_file_to_perl("$ENV{WORKSPACE}/DistInfo.json");

my $ShellStreamedit = "_streamedit.ciom";
my $OldPwd = getcwd();
our $ExcutorsStatus = [];
our $Platform = "";
our $AppVcaHome = "";
our $CiomData = {};
our $doUpload = "";
our $distDetail = {};
our $DynamicParams ={};
our $appName = "";
our $version = "";
our	$cloudId = "";
our $wsLog = "build.log";

sub injectPlatformDependency() {
	require "$ENV{CIOM_SCRIPT_HOME}/${Platform}.spec.pl";
}

sub intialGlobalVars(){
	$Platform = $DistInfo->{os};
	$AppVcaHome = $DistInfo->{appVcaHome};
	$CiomData = json_file_to_perl("$AppVcaHome/ciom.json");
	$doUpload = $DistInfo->{doUpload};
	$distDetail = $DistInfo->{distInfo}->[$executorIdx];
	$DynamicParams = $DistInfo->{dynamicParams};
	$appName = $DistInfo->{appName};
	$version = $DistInfo->{version};
	$cloudId = $DistInfo->{cloudId};
}

sub enterWorkspace() {
	my $ws = $DistInfo->{distInfo}->[$executorIdx]->{workspace};
	
	my $appWorkspace = "${ws}/$appName";
	#print $appWorkspace ;
	#print "\n";
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
	#my $username = $CiomData->{scm}->{username};
	#my $password = $CiomData->{scm}->{password};
	my $username = "jenkins";
	my $password = "pwdasdwx";

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
	my $ws = getcwd();
	logBuildingStatus(1,"=== start update code for ${ws} ===");
	updateCode(1);
	logBuildingStatus(1,"=== end update code for ${ws} ===");
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

	my $appExtName = $Platform eq 'ios' ? 'ipa' : 'apk';
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
	logBuildingStatus(0,"=== start streameditConfs4Org ===");
	streamedit($streameditItems);
	logBuildingStatus(0,"=== end streameditConfs4Org ===");
}

sub streameditConfs4AllOrgs() {
	my $streameditItems = $CiomData->{streameditItems};
	my $orgCodes = join(',',@{$distDetail->{needToBuildOrgCodes}});
	$ciomUtil->exec("\n\n\necho '$ENV{BUILD_NUMBER} - $orgCodes' >> _streamedit.ciom.all");
	$ciomUtil->exec("echo ciom.global >> _streamedit.ciom.all");
	logBuildingStatus(0,"=== start streameditConfs4AllOrg ===");
	streamedit($streameditItems);
	logBuildingStatus(0,"=== end streameditConfs4AllOrg ===");
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

sub logBuildFinishedOrgs($) {
	my $code = $_[0];
	my $needBuildCnt = $#{$DistInfo->{distInfo}->[$executorIdx]->{needToBuildOrgCodes}} + 1;

	push(@{$DistInfo->{distInfo}->[$executorIdx]->{finishedBuildOrgCodes}}, $code);
	my $alreadyBuiltCnt = $#{$DistInfo->{distInfo}->[$executorIdx]->{finishedBuildOrgCodes}} + 1;

	printf "On executor${executorIdx}, ${alreadyBuiltCnt}/${needBuildCnt} finished\n";
}

sub logBuildingStatus($$) {
	my $printToConsole = $_[0];
	my $logContent = $_[1];
	my $now_string = strftime "%Y-%m-%d %H:%M:%S", localtime;

	if ( $printToConsole == 1){
		print "$logContent \n";
	}
	$ciomUtil->appendToFile($wsLog,"$now_string : $logContent \n");
}

sub clearBuilingLog() {
	$ciomUtil->exec("rm -rf $wsLog");
	$ciomUtil->writeToFile($wsLog,"");
}

sub buildOrgs() {
	my @childs;
	my $need2BuildOrgCodes = $distDetail->{needToBuildOrgCodes};
	my $cnt = $#{$need2BuildOrgCodes} + 1;
	clearBuilingLog();
	for (my $i = 0; $i < $cnt; $i++) {
		my $code = $need2BuildOrgCodes->[$i];
		$DynamicParams->{OrgCode} = $code;
		logBuildingStatus(1,"###############Start to build org <$code> on executor${executorIdx}################");
		revertCode();
		replaceOrgCustomizedFiles($code);
		streameditConfs4AllOrgs();
		streameditConfs4Org($code);
		if ( $Platform eq 'ios') {
			build($code);
		}
		else {
			build();
		}
		cleanAfterOrgBuild();
		moveApppkgFile($code);
		if ($doUpload eq 'YES' ) {
			my $pid = fork();
			if (!defined($pid)) {
        		print "Error in fork for uploadOrgPkgs: $!";
        		exit 1;
    		}
                                  
    		if ($pid == 0) {
    			#print "Child $i$j : My pid = $$\n";
				uploadOrgPkgs($code);
        		#print "Child $i$j : end\n";
        		exit 0;
        	}
        	else {
        		push(@childs, $pid);
        	}
		}
		logBuildingStatus(1,"###############Finish building org <$code> on executor${executorIdx}###############\n");
		logBuildFinishedOrgs($code);
	}

	if ($doUpload eq 'YES' ) {
		foreach (@childs) {
			waitpid($_, 0);
		}
	}
}

sub getUploadRemoteURI() {
	my $publishto = $CiomData->{publishto};
	my $ip = $publishto->{ip};
	my $user = $publishto->{user} || 'ciom';
	my $path = $publishto->{path};

	return "$user\@$ip:/$path/";
}

sub uploadOrgPkgs($) {
	my $code = shift;

	if (!defined($CiomData->{publishto})) {
		return;
	}

	my $remoteURI = getUploadRemoteURI();
	my $pkgName = getAppFinalPkgName($code);
	$ciomUtil->exec("scp $ApppkgPath/$pkgName $remoteURI");
}

sub uploadAllPkgs() {
	if (!defined($CiomData->{publishto})) {
		return;
	}

	my $remoteURI = getUploadRemoteURI();
	$ciomUtil->exec("scp -r $ApppkgPath/* $remoteURI");
}

sub main() {
	intialGlobalVars();
	injectPlatformDependency();

	enterWorkspace();
	updateCode(0);
	globalPreAction();
	buildOrgs();
	globalPostAction();
	leaveWorkspace();
 
	#return getBuildError();
}

sub main2() {
	intialGlobalVars();
	print "executorIdx is $executorIdx \n";
	print Dumper($DistInfo);
}

exit main();
