#!/usr/bin/perl -W -I /var/lib/jenkins/workspace/ciom
# 
#

use strict;
use English;
use Data::Dumper;
use Cwd;
use CiomUtil;

my $cloudId = $ARGV[0];
my $appName = $ARGV[1];
my $ciomUtil = new CiomUtil(0);
my $OldPwd = getcwd();

sub enterWorkspace() {
	;
}

sub leaveWorkspace() {
	chdir($OldPwd);
}

sub deploy() {

}

sub main() {
	enterWorkspace();
	deploy();
	leaveWorkspace();
}

main();
