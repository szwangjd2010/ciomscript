#!/usr/bin/perl -W
# 
# add this for windows scp, 
# cause windows ssh client scp speed is very slow
#

use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use English;
use Data::Dumper;
use Cwd;
use CiomUtil;
use JSON;
use File::Slurp;

my $ver = $ARGV[0];
my $env = $ARGV[1];
my $appName = $ARGV[2];

my $ciomUtil = new CiomUtil(1);
my $OldPwd = getcwd();

my $AppVcaEnv = "$ENV{CIOM_VCA_HOME}/$ver/pre/$env";

sub enterWorkspace() {
	;
}

sub getAppCiomJsonFile() {
	return "$AppVcaEnv/$appName/ciom.json";
}

sub getAppPackageFile() {
	return "$ENV{WORKSPACE}/$appName.zip";
}

sub leaveWorkspace() {
	chdir($OldPwd);
}

sub getAppCiomJson() {
	my $txt = read_file(getAppCiomJsonFile());
	my $json = JSON->new->utf8->decode($txt);

	return $json
}

sub upload($$) {
	my $file = shift;
	my $hosts = shift;
	my $cnt = $#{$hosts} + 1;

	for (my $i = 0; $i < $cnt; $i++) {
		$ciomUtil->exec("scp $file ciom\@$hosts->[$i]->{ip}:/c:/");
	}

}

sub main() {
	enterWorkspace();
	
	my $json = getAppCiomJson();
	my $packageFile = getAppPackageFile();
	upload($packageFile, $json->{hosts});

	leaveWorkspace();
}

main();
