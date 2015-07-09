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
my $asRoot = $ARGV[3] || 'NotAsRoot';

my $ciomUtil = new CiomUtil(1);
my $OldPwd = getcwd();

my $AppCiomFile="$ENV{CIOM_VCA_HOME}/$version/pre/$cloudId/$appName.ciom";
require $AppCiomFile;
our $Cloud;

sub enterWorkspace() {
	;
}

sub leaveWorkspace() {
	chdir($OldPwd);
}

sub deploy() {
	my $shDeploy2Host = "$ENV{CIOM_SCRIPT_HOME}/deploy.app.to.host.with.multi.tomcats.sh";
	
	my $hosts = $Cloud->{hosts};
	my $cnt = $#{$hosts} + 1;
	for (my $i = 0; $i < $cnt; $i++) {
		my $cmd = sprintf("%s %s %s %s %s %s",
				$shDeploy2Host,
				$hosts->[$i]->{ip},
				$hosts->[$i]->{port} || $Cloud->{port},
				$hosts->[$i]->{tomcatParent} || $Cloud->{tomcatParent},
				$appName,
				$asRoot
		);

		$ciomUtil->exec($cmd);
	}
}

sub main() {
	enterWorkspace();
	deploy();
	leaveWorkspace();
}

main();
