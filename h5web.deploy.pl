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
my $appName = $ARGV[2];

my $ciomUtil = new CiomUtil(1);
my $OldPwd = getcwd();

my $AppCiomFile="$ENV{CIOM_VCA_HOME}/$version/pre/$cloudId/$appName.ciom";
my $MyWorkspace="$ENV{WORKSPACE}";
my $AppTargetRoot ;
my $CiomHome ;
my $CiomBackUpHome;
require $AppCiomFile;
our $Cloud;

our $SshInfo = {};

sub initial4Deploy() {
	$SshInfo->{port} = "22"; 
	$SshInfo->{user} = "root"; 
	$SshInfo->{host} = $Cloud->{host};
	$AppTargetRoot = $Cloud->{appTargetRoot};
	$CiomHome = $Cloud->{ciomHome};
	$CiomBackUpHome = $Cloud->{ciomBackUpHome};

	#make sure folders exist
	my $mkdirCmd = "mkdir -p $CiomHome; mkdir -p $CiomBackUpHome";
	$SshInfo->{cmd} = "$mkdirCmd";
	$ciomUtil->remoteExec($SshInfo);
}

sub enterWorkspace() {
	chdir($MyWorkspace);
}

sub deployH5() {

	#Step1, move zip to target machine
	$ciomUtil->exec("scp -r $appName.zip root\@$Cloud->{host}:$CiomHome/");

	#Step2, remote deployment
	my $timestamp = strftime("%04Y%02m%02d.%02k%02M%02S",localtime());
	my $remoteBackupCmd = "mv $AppTargetRoot/$appName $CiomBackUpHome/$appName.$timestamp";
	my $remoteUnzipCmd = "unzip -o $CiomHome/$appName.zip -d $CiomHome";
	my $mvAppToTargetCmd = "mv $CiomHome/$appName/app $AppTargetRoot/$appName";
	$SshInfo->{cmd} = "( $remoteBackupCmd; $remoteUnzipCmd; $mvAppToTargetCmd )";
	$ciomUtil->remoteExec($SshInfo);
}

sub deploySmartAdmin() {
#(cd skyeyeweb; zip -r ../skyeyeweb.zip *)
#		scp skyeyeweb.zip root@172.17.128.225:/usr/share/nginx/html/ciom/
#		ssh root@172.17.128.225 "mkdir -p /usr/share/nginx/html/skyeyeweb; cd /usr/share/nginx/html/skyeyeweb; rm -rf *; unzip ../ciom/skyeyeweb.zip"
	$ciomUtil->exec("zip -r $appName.zip $appName/*; scp -r $appName.zip root\@$Cloud->{host}:$CiomHome/");
	#Step2, remote deployment
	my $timestamp = strftime("%04Y%02m%02d.%02k%02M%02S",localtime());
	my $remoteBackupCmd = "mv $AppTargetRoot/$appName $CiomBackUpHome/$appName.$timestamp";
	my $remoteUnzipCmd = "unzip -o $CiomHome/$appName.zip -d $CiomHome";
	my $mvAppToTargetCmd = "mv $CiomHome/$appName $AppTargetRoot/$appName";
	$SshInfo->{cmd} = "( $remoteBackupCmd; $remoteUnzipCmd; $mvAppToTargetCmd )";
	$ciomUtil->remoteExec($SshInfo);
}

sub deploy() {
	if ( $Cloud->{type} eq 'smartadmin') {
		deploySmartAdmin();
		return;
	}

	if ( $Cloud->{type} eq 'h5web') {
		deployH5();
		return;
	}

	print "[ciom] deploy type incorrect\n";
	exit 1;
}

sub leaveWorkspace() {
	chdir($OldPwd);
}

sub main() {
	initial4Deploy();
	enterWorkspace();
	deploy();
	leaveWorkspace();
}

main();