#!/usr/bin/perl -W
#

use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use English;
use Data::Dumper;
use POSIX qw(strftime);
use Cwd;
use CiomUtil;


my $version = $ARGV[0];
my $cloudId = $ARGV[1];

my $ciomUtil = new CiomUtil(1);
my $OldPwd = getcwd();

my $AppCiomFile="$ENV{CIOM_VCA_HOME}/$version/pre/$cloudId/platform.url.svc.ciom";
my $MyWorkspace="$ENV{WORKSPACE}";
my $AppTargetRoot ;
my $CiomHome ;
my $CiomBackUpHome;
my $SvcPort;
my $LogFullPath;
require $AppCiomFile;
our $Cloud;

our $SshInfo = {};

sub initial4Deploy() {
	$SshInfo->{port} = "22"; 
	$SshInfo->{user} = "root"; 
	$SshInfo->{host} = $Cloud->{host};
	$AppTargetRoot = $Cloud->{appTargetRoot};
	$SvcPort = $Cloud->{svcPort};
	$LogFullPath = $Cloud->{logFullpath};
	#make sure folders exist
	#my $mkdirCmd = "mkdir -p $CiomHome; mkdir -p $CiomBackUpHome";
	#$SshInfo->{cmd} = "$mkdirCmd";
	#$ciomUtil->remoteExec($SshInfo);
}

sub enterWorkspace() {
	chdir($MyWorkspace);
}

sub killProcess() {
	my $killProcCmd = "netstat -nlp | grep 18085 | awk '{print \\\$7}' | awk -F\\\"/\\\" '{print \\\$1}' ";
	#my $killProcCmd = "netstat -nlp | grep $SvcPort | awk '{print \\\$7}' | awk -F\\\"/\\\" '{print \\\$1}' | xargs kill -9";
	$ciomUtil->exec("ssh -p $SshInfo->{port} $SshInfo->{user}\@$SshInfo->{host} \"$killProcCmd\"");
}

sub startUrlService() {
	#my $cmd = "nohup node $AppTargetRoot/app.js >> $LogFullPath &";
	#$SshInfo->{cmd} = "$cmd";
	#$ciomUtil->remoteExec($SshInfo);
}

sub checkLog() {
	my $cmd = "tail -n 50 $LogFullPath";
	$SshInfo->{cmd} = "$cmd";
	$ciomUtil->remoteExec($SshInfo);
}

sub leaveWorkspace() {
	chdir($OldPwd);
}

sub main() {
	initial4Deploy();
	enterWorkspace();
	killProcess();
	startUrlService();
	checkLog();
	leaveWorkspace();
}

main();