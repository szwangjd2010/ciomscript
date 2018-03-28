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
	#my $timestamp = strftime("%04Y%02m%02d.%02k%02M%02S",localtime());
	my $remoteBackupCmd = "mv $AppTargetRoot/$appName $CiomBackUpHome/$appName.\$version";
	my $remoteUnzipCmd = "unzip -q -o $CiomHome/$appName.zip -d $CiomHome";
	my $mvAppToTargetCmd = "mv $CiomHome/$appName/app $AppTargetRoot/$appName";
	my $getVersionTxt = "version=\$(head -1 $AppTargetRoot/$appName/version.txt)";
	$SshInfo->{cmd} = "( $getVersionTxt; $remoteBackupCmd; $remoteUnzipCmd; $mvAppToTargetCmd )";
	$ciomUtil->remoteExec($SshInfo);
}

sub deployH5new() {
	#Step1, move zip to target machine
	$ciomUtil->exec("scp -r $appName.zip root\@$Cloud->{host}:$CiomHome/");

	#Step2, remote deployment
	#my $timestamp = strftime("%04Y%02m%02d.%02k%02M%02S",localtime());
	my $remoteBackupCmd = "mv $AppTargetRoot/$appName $CiomBackUpHome/$appName.\$version";
	my $remoteUnzipCmd = "unzip -q -o $CiomHome/$appName.zip -d $CiomHome";
	my $mvAppToTargetCmd = "mv $CiomHome/$appName/src $AppTargetRoot/$appName";
	my $getVersionTxt = "version=\$(head -1 $AppTargetRoot/$appName/version.txt)";
	$SshInfo->{cmd} = "( $getVersionTxt; $remoteBackupCmd; $remoteUnzipCmd; $mvAppToTargetCmd )";
	$ciomUtil->remoteExec($SshInfo);
}

sub deployH5WithTarget() {
	my $folderTarget = $Cloud->{folderTarget};

	#Step1, move zip to target machine
	$ciomUtil->exec("scp -r $appName.zip root\@$Cloud->{host}:$CiomHome/");

	#Step2, remote deployment
	#my $timestamp = strftime("%04Y%02m%02d.%02k%02M%02S",localtime());
	my $remoteBackupCmd = "mv $AppTargetRoot/$appName $CiomBackUpHome/$appName.\$version";
	my $remoteUnzipCmd = "unzip -q -o $CiomHome/$appName.zip -d $CiomHome";
	my $mvAppToTargetCmd = "mv $CiomHome/$appName/$folderTarget $AppTargetRoot/$appName";
	my $getVersionTxt = "version=\$(head -1 $AppTargetRoot/$appName/version.txt)";
	$SshInfo->{cmd} = "( $getVersionTxt; $remoteBackupCmd; $remoteUnzipCmd; $mvAppToTargetCmd )";
	$ciomUtil->remoteExec($SshInfo);
}

sub deployDirectly() {
	#Step1, zip and move to target machine
	$ciomUtil->exec("zip -qr $appName.zip $appName/*; scp -r $appName.zip root\@$Cloud->{host}:$CiomHome/");
	#Step2, remote deployment
	#my $timestamp = strftime("%04Y%02m%02d.%02k%02M%02S",localtime());
	my $getVersionTxt = "version=\$(head -1 $AppTargetRoot/$appName/version.txt)";
	my $remoteBackupCmd = "mv $AppTargetRoot/$appName $CiomBackUpHome/$appName.\$version";
	my $remoteUnzipCmd = "unzip -q -o $CiomHome/$appName.zip -d $CiomHome";
	my $mvAppToTargetCmd = "mv $CiomHome/$appName $AppTargetRoot/$appName";
	$SshInfo->{cmd} = "( $getVersionTxt; $remoteBackupCmd; $remoteUnzipCmd; $mvAppToTargetCmd )";
	$ciomUtil->remoteExec($SshInfo);
}

sub chmod4AppTarget() {
	if (defined($Cloud->{chmod})) {
		$SshInfo->{cmd} = "chmod $Cloud->{chmod} $AppTargetRoot/$appName";
		$ciomUtil->remoteExec($SshInfo);
	}
}

sub deploy() {
	if ( $Cloud->{type} eq 'directly') {
		deployDirectly();
		return;
	}

	if ( $Cloud->{type} eq 'h5web') {
		deployH5();
		return;
	}

	if ( $Cloud->{type} eq 'h5webnew') {
		deployH5new();
		return;
	}

	if ( $Cloud->{type} eq 'h5webWithTarget') {
		deployH5WithTarget();
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
	chmod4AppTarget();
	leaveWorkspace();
}

main();