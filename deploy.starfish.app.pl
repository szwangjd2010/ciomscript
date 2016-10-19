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
use JSON;
use String::Escape 'escape';
use open ":encoding(utf8)";
use open IN => ":encoding(utf8)", OUT => ":utf8";
use IO::Handle;
use POSIX qw(strftime);
STDOUT->autoflush(1);

sub getPlatform();

our $DistInfo = {};
our $version = $ARGV[0];
our $cloudId = $ARGV[1]; #$cloudId, should be "andriod[.*]", "ios[.*]"
our $appName = $ARGV[2];
our $platform = $ARGV[3];
#our $doUpload = $ENV{UploadPackage} || 'NO';

our $ciomUtil = new CiomUtil(1);
our $AppVcaHome = "$ENV{CIOM_VCA_HOME}/$version/pre/$cloudId/$appName";
our $ApppkgPath = "$ENV{JENKINS_HOME}/jobs/$ENV{JOB_NAME}/builds/$ENV{BUILD_NUMBER}/app";
our $CiomData = json_file_to_perl("$AppVcaHome/ciom.json");
our $wsLog = "build.log";
#our $Slave4MobileDeploy = json_file_to_perl("$ENV{CIOM_SCRIPT_HOME}/slaves4mobiledeploy.json");

my $OldPwd = getcwd();

sub getBuildLogFile() {
	return "$ENV{JENKINS_HOME}/jobs/$ENV{JOB_NAME}/builds/$ENV{BUILD_NUMBER}/log";
}

sub getBuildError() {
	my $logFile = getBuildLogFile();
	my $buildFailedCnt = $ciomUtil->execWithReturn("grep -c 'with exit code 1' $logFile");
	return $buildFailedCnt - 1;	
}

sub injectPlatformDependency() {
	require "$ENV{CIOM_SCRIPT_HOME}/${platform}.starfish.pl";	
}

sub enterWorkspace() {
	my $appWorkspace = "$ENV{WORKSPACE}";
	print $appWorkspace ;
	print "\n";
	if (! -d $appWorkspace) {
		$ciomUtil->exec("mkdir -p $appWorkspace");
	}
	chdir($appWorkspace);
}

sub leaveWorkspace() {
	chdir($OldPwd);
}

sub revertCode() {
	if (! -d $appName) {
		my $gitRepos = $CiomData->{gitRepos};
		$ciomUtil->exec("git clone $gitRepos");
	}
	else {
		my $currentCwd = getcwd();
		chdir("$currentCwd/$appName");
		$ciomUtil->exec("git pull origin develop");
		chdir($currentCwd);
	}
}

sub makeApppkgDirectory() {
	$ciomUtil->exec("mkdir $ApppkgPath");
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

sub main() {
	enterWorkspace();
	injectPlatformDependency();
	makeApppkgDirectory();
	revertCode();
	logApppkgUrl();
	clearBuilingLog();
	build();
	return getBuildError();
}

exit main();
