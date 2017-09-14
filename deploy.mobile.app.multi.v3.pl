#!/usr/bin/perl -W
# 
#
use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use Encode;
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
our $ShellStreamedit = "_streamedit.ciom";
my $OldPwd = getcwd();
our $ExcutorsStatus = [];
our $Platform = "";
our $AppVcaHome = "";
our $CiomData = {};
our $doUpload = "";
our $doUpload2Pgyer = "";
our $pgyComments = "";
our $distDetail = {};
our $DynamicParams ={};
our $appName = "";
our $version = "";
our	$cloudId = "";
our $wsLog = "build.log";
our $orgCount;
our $need2BuildOrgCodes;

sub injectPlatformDependency() {
	if ($Platform eq 'ios') {
		require "$ENV{CIOM_SCRIPT_HOME}/${Platform}.spec.v2.pl";
	}
	else {
		require "$ENV{CIOM_SCRIPT_HOME}/${Platform}.spec.v3.pl";
	}
	
}

sub intialGlobalVars(){
	$Platform = $DistInfo->{os};
	$AppVcaHome = $DistInfo->{appVcaHome};
	$CiomData = json_file_to_perl("$AppVcaHome/ciom.json");
	$doUpload = $DistInfo->{doUpload};
	$doUpload2Pgyer = $DistInfo->{doUpload2Pgyer};
	$pgyComments = $DistInfo->{pgyComments};
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

sub updateCode($){
	my $dorevert = shift || 0;
	my $repos = $CiomData->{scm}->{repos};
	my $cnt = $#{$repos} + 1;
	for (my $i = 0; $i < $cnt; $i++) {
		my $scmInfo = $repos->[$i];
		my $gitPostfix = ".git";
		if ($scmInfo->{url} =~ /$gitPostfix/) {
			updateCodeWithGit($dorevert,$scmInfo);
		}
		else{
			updateCodeWithSvn($dorevert,$scmInfo);
		}
	}
}

sub updateCodeWithSvn($$) {
	my $doRevert = shift;
	my $scmRepoInfo = shift;

	my $username = "jenkins";
	my $password = "pwdasdwx";
	my $cmdSvnPrefix = "svn --non-interactive --username $username --password '$password'";
	my $cmdRmUnversionedTpl = "$cmdSvnPrefix status %s | grep -P '^\\?' | awk '{print \$2}' | xargs -I{} rm -rf '{}'";

	my $name = $scmRepoInfo->{name};
	my $url = $scmRepoInfo->{url};
	#$url = instantiateDynamicParamsInStr($url);
	$url = $ciomUtil->removeLastSlashForUrl($url);
	if ($doRevert == 1) {
		$ciomUtil->execNotLogCmd(sprintf($cmdRmUnversionedTpl, $name));
		$ciomUtil->exec("$cmdSvnPrefix revert -R $name");
	} else {
		if (! -d "$name/.svn" || '0' == $ciomUtil->execWithReturn("svn info $name|grep -c \'$url\$\'")){
			$ciomUtil->exec("rm -rf $name");
		}
		if (! -d $name) {
			$ciomUtil->exec("$cmdSvnPrefix co $url $name");
		} else {
			$ciomUtil->execNotLogCmd(sprintf($cmdRmUnversionedTpl, $name));
			$ciomUtil->exec("$cmdSvnPrefix revert -R $name");
			$ciomUtil->exec("$cmdSvnPrefix update $name");			
		}			
	}
}

sub updateCodeWithGit($$) {
	my $doRevert = shift;
	my $scmRepoInfo = shift;

	my $name = $scmRepoInfo->{name};
	my $url = $scmRepoInfo->{url};
	my $branch = $scmRepoInfo->{branch} || "master";
	

	if ($doRevert == 1) {
		chdir("$name");
		$ciomUtil->exec("git checkout . && git clean -xdf");
		chdir("..");
	} else {
		if (! -d "$name/.git" || '0' == $ciomUtil->execWithReturn("grep -c $url $name/.git/config")) {
			$ciomUtil->exec("rm -rf $name");
		}
		if (! -d $name) {
			$ciomUtil->exec("git clone $url $name");
		}

		chdir("$name");
		$ciomUtil->exec("git checkout . && git clean -xdf");
		$ciomUtil->exec("git checkout master");
		$ciomUtil->exec("git pull");
		if (defined($scmRepoInfo->{tag})) {
			my $tag = $scmRepoInfo->{tag};
			if ( $tag ne '') {
				$ciomUtil->exec("git checkout $tag");
			}
		} else {
			$ciomUtil->exec("git checkout $branch");
		}
		chdir("..");
	}
}

sub revertCode() {
	my $ws = getcwd();
	logBuildingStatus(1,"=== start update code for ${ws} ===");
	updateCode(1);
	#updateCodeWithSvn(1);
	logBuildingStatus(1,"=== end update code for ${ws} ===");
}

sub replaceOrgCustomizedFiles($) {
	my $code = $_[0];
	my $orgCustomizedHome = "$AppVcaHome/resource/$code";
	$ciomUtil->exec("/bin/cp -rf $orgCustomizedHome/* ./");
}

sub copyPlistFiles() {
	$ciomUtil->exec("/bin/cp -rf $AppVcaHome/*.plist ./");
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
	$need2BuildOrgCodes = $distDetail->{needToBuildOrgCodes};
	$orgCount = $#{$need2BuildOrgCodes} + 1;
	clearBuilingLog();
	
	streameditConfs4AllOrgs();
	initial();

	if ($Platform eq 'ios') {
		copyPlistFiles();
		resyncSourceCode();
		achiveAndExportIpa();
	}
	else {
		resyncSourceCode();
	}

	for (my $i = 0; $i < $orgCount; $i++) {
		my $code = $need2BuildOrgCodes->[$i];
		logBuildingStatus(1,"###############Start to build org <$code> on executor${executorIdx}################");
		if ($Platform eq 'ios') {
			updateResourceAndPackage($code);
		}
		else {
			#revertCode();
			replaceOrgCustomizedFilesToSlave($code);
			remoteStreameditConfs4Org($code);
			build();
		}
		#cleanAfterOrgBuild();
		moveApppkgFile($code);
		uploadPackage($code);
		logBuildingStatus(1,"###############Finish building org <$code> on executor${executorIdx}###############\n");
		logBuildFinishedOrgs($code);
	}
}

sub getUploadRemoteURI() {
	my $publishto = $CiomData->{publishto};
	my $ip = $publishto->{ip};
	my $user = $publishto->{user} || 'ciom';
	my $path = $publishto->{path};

	return "$user\@$ip:/$path/";
}

sub uploadPackage($) {
	my $code = shift;
	if ($doUpload eq 'YES' ) {
		uploadOrgPkg($code);
	}
	if ($doUpload2Pgyer eq 'YES') {
		uploadPkgs2Pgyer($code);
	}
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

sub uploadPkgs2Pgyer($) {
	my $code = shift;
	if (!defined($CiomData->{pgyer})) {
		return;
	}
	my $appKey = $CiomData->{pgyer}->{appKey};
	my $userKey = $CiomData->{pgyer}->{userKey};
	my $uploadApiUrl = $CiomData->{pgyer}->{uploadApiUrl};
	my $pkgName = getAppFinalPkgName($code);
	my $updateDes = decode('utf8',$pgyComments);
	my $uploadCmd = "curl -F \"updateDescription=$updateDes\" -F \"file=\@$ApppkgPath/$pkgName\" -F \"_api_key=$appKey\" -F \"uKey=$userKey\" $uploadApiUrl";
	$ciomUtil->exec("$uploadCmd");
}

sub main() {
	intialGlobalVars();
	injectPlatformDependency();

	enterWorkspace();
	updateCode(0);
	#updateCodeWithSvn(0);
	globalPreAction();
	buildOrgs();
	globalPostAction();
	leaveWorkspace();
 
	#return getBuildError();
}

exit main();
