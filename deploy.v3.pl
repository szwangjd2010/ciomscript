#!/usr/bin/perl -W -I /var/lib/jenkins/workspace/ciom
# 
#
use strict;
use English;
use Data::Dumper;
use Cwd;
use CiomUtil;

require "$ENV{JENKINS_HOME}/workspace/ciom/clouds.ciom";
our $Clouds;

my $cloudId = $ARGV[0];
my $appName = $ARGV[1];
my $asRoot = $ARGV[2] || 'NotAsRoot';
my $ciomUtil = new CiomUtil(1);
my $OldPwd = getcwd();

sub enterWorkspace() {
	;
}

sub leaveWorkspace() {
	chdir($OldPwd);
}

sub deploy() {
	my $cloud = $Clouds->{$cloudId};
	my $hosts = $cloud->{hosts};
	my $cnt = $#{$hosts} + 1;
	for (my $i = 0; $i < $cnt; $i++) {
		my $cmd = sprintf("%s %s %s %s %s %s",
				"$ENV{JENKINS_HOME}/workspace/ciom/deploy.app.to.host.with.multi.tomcats.sh",
				$hosts->[$i]->{ip},
				$hosts->[$i]->{port} || $cloud->{port},
				$hosts->[$i]->{tomcatParent} || $cloud->{tomcatParent},
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
