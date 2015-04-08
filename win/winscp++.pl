#!/usr/bin/perl -W -I /var/lib/jenkins/workspace/ciom
# 
# add this for windows scp, 
# cause windows ssh client scp speed is very slow
#

use strict;
use English;
use Data::Dumper;
use Cwd;
use CiomUtil;
use JSON;

my $dotnetCiomJsonFile = $ARGV[0];
my $ciomUtil = new CiomUtil(1);
my $OldPwd = getcwd();

sub enterWorkspace() {
	;
}

sub leaveWorkspace() {
	chdir($OldPwd);
}

sub getDotnetCiomJson() {

}

sub main() {
	enterWorkspace();
	deploy();
	leaveWorkspace();
}

main();
