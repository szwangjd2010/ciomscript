#!/usr/bin/perl -W -I /var/lib/jenkins/workspace/ciom
# 
#
use strict;
use English;
use Data::Dumper;
use Cwd;
use CiomUtil;
use JSON::Parse 'json_file_to_perl';

my $version = $ARGV[0];
my $cloudId = $ARGV[1];
my $appName = $ARGV[2];

my $ciomUtil = new CiomUtil(1);
my $OldPwd = getcwd();

my $AppCiomFile="$ENV{JENKINS_HOME}/workspace/ver.env.specific/$version/pre/$cloudId/$appName/ciom.json";
my $CiomData = json_file_to_perl($AppCiomFile);

print Dumper($CiomData); 

sub enterWorkspace() {
	;
}

sub leaveWorkspace() {
	chdir($OldPwd);
}

sub main() {
	enterWorkspace();
	leaveWorkspace();
}

main();
