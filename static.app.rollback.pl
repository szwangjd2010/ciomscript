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
my $backUpTarget = $ARGV[3];

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

sub initial() {
	$SshInfo->{port} = "22"; 
	$SshInfo->{user} = "root"; 
	$SshInfo->{host} = $Cloud->{host};
	$AppTargetRoot = $Cloud->{appTargetRoot};
	$CiomHome = $Cloud->{ciomHome};
	$CiomBackUpHome = $Cloud->{ciomBackUpHome};
}

sub checkBackupExist() {
	system "ssh", "$SshInfo->{user}\@$SshInfo->{host}" , "test", "-e", "$CiomBackUpHome/$backUpTarget";
	my $rc = $? >> 8;
	if ($rc) {
		printf "backup not exit";
		exit 1;
	}
}

sub enterWorkspace() {
	chdir($MyWorkspace);
}

sub rollback() {
	#remote actions

	my $getVersionTxt = "version=\$(head -1 $AppTargetRoot/$appName/version.txt)";
	my $remoteBackupCmd = "mkdir -p $CiomBackUpHome/$appName.\$version; cp -r $AppTargetRoot/$appName/* $CiomBackUpHome/$appName.\$version/";
	my $remoteCleanCmd = "rm -rf $AppTargetRoot/$appName/*";
	my $cpAppToTargetCmd = "cp -r $CiomBackUpHome/$backUpTarget/* $AppTargetRoot/$appName/";
	$SshInfo->{cmd} = "( $getVersionTxt; $remoteBackupCmd; $remoteCleanCmd; $cpAppToTargetCmd )";
	$ciomUtil->remoteExec($SshInfo);
}

sub leaveWorkspace() {
	chdir($OldPwd);
}

sub chmod4AppTarget() {
	if (defined($Cloud->{chmod})) {
		$SshInfo->{cmd} = "chmod $Cloud->{chmod} $appTargetRoot/$appName";
		$ciomUtil->remoteExec($SshInfo);
	}
}

sub main() {
	initial();
	checkBackupExist();
	enterWorkspace();
	rollback();
	chmod4AppTarget();
	leaveWorkspace();
}

main();