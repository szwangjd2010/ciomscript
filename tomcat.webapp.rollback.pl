#!/usr/bin/perl -W
#

use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use English;
use Data::Dumper;
use Cwd;
use CiomUtil;

my $version = $ARGV[0];
my $cloudId = $ARGV[1];
my $appName = $ARGV[2];
my $backupTarget = $ARGV[3];
my $asRoot = $ARGV[4] || 'NotAsRoot';


my $ciomUtil = new CiomUtil(1);
my $OldPwd = getcwd();

my $AppCiomFile="$ENV{CIOM_VCA_HOME}/$version/pre/$cloudId/$appName.ciom";
my $MyWorkspace="$ENV{WORKSPACE}/$appName/target";
my $AppPackageFile="$appName.war";
require $AppCiomFile;
our $Cloud;

sub enterWorkspace() {
	chdir($MyWorkspace);
}

sub leaveWorkspace() {
	chdir($OldPwd);
}

sub rollback() {
	my $shRollbackOnHost = "$ENV{CIOM_SCRIPT_HOME}/rollback.app.on.host.with.multi.tomcats.sh";
	
	my $hosts = $Cloud->{hosts};
	my $cnt = $#{$hosts} + 1;
	for (my $i = 0; $i < $cnt; $i++) {
		my $cmd = sprintf("%s %s %s %s %s \"%s\" %s",
				$shRollbackOnHost,
				$hosts->[$i]->{ip},
				$hosts->[$i]->{port} || $Cloud->{port},
				$hosts->[$i]->{tomcatParent} || $Cloud->{tomcatParent},
				$appName,
				$backupTarget,
				$asRoot
		);

		$ciomUtil->exec($cmd);
	}
}

sub main() {
	enterWorkspace();
	rollback();
	leaveWorkspace();
}

main();
