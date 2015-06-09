#!/usr/bin/perl -W -I /var/lib/jenkins/workspace/ciom
# 
#
use strict;
use English;
use Data::Dumper;
use Cwd;
use CiomUtil;

my $version = $ARGV[0];
my $cloudId = $ARGV[1];
my $appName = $ARGV[2];

my $ciomUtil = new CiomUtil(1);
my $AppVcaHome="$ENV{JENKINS_HOME}/workspace/ver.env.specific/$version/pre/$cloudId/$appName";

sub main() {
	chdir($AppVcaHome);
	$ciomUtil->exec("svn revert -R");
	$ciomUtil->exec("svn update");
}

main();
