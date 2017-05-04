#!/usr/bin/perl -W
#

use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use English;
use Data::Dumper;
use Cwd;
use CiomUtil;
use JSON::Parse 'json_file_to_perl';

my $version = $ARGV[0];
my $cloudId = $ARGV[1];
my $appName = $ARGV[2];
my $jobName = $ARGV[3];

my $ciomUtil = new CiomUtil(1);
my $OldPwd = getcwd();

my $AppCiomFile="$ENV{CIOM_VCA_HOME}/$version/pre/$cloudId/$appName.ciom";
my $AppCiomJsonFile="$ENV{CIOM_VCA_HOME}/$version/pre/$cloudId/$appName/ciom.json";
#require $AppCiomFile;
our $Cloud;
our $CiomData;
#my $remoteHost= $Cloud->{hosts}->[0]->{ip} || $Cloud->{host};
my $remoteHost;
my $wsRoot;
my $isPsTarget="false";
my $options="";
my $jobConfigFile="$ENV{JENKINS_HOME}/jobs/${jobName}/config.xml";
my $user;

sub initial() {
	if ( -e $AppCiomFile) {
		require $AppCiomFile;
		$remoteHost = $Cloud->{hosts}->[0]->{ip} || $Cloud->{host};
		$wsRoot = $Cloud->{tomcatParent} || $Cloud->{hosts}->[0]->{tomcatParent} || $Cloud->{ciomBackUpHome};
		$user = "root";
	}
	if ( -e $AppCiomJsonFile) {
		$isPsTarget = "true";
		$CiomData = json_file_to_perl("$AppCiomJsonFile");
		$remoteHost = $CiomData->{hosts}->[0]->{ip};
		$wsRoot = "$CiomData->{app3wPath}";
		$user = "ciom";
	}
}

sub enterWorkspace() {
	;
}

sub leaveWorkspace() {
	chdir($OldPwd);
}

sub getBackupListOptions() {
	my $cmd;	
	if ( $isPsTarget eq "true" ) {
		$cmd="ssh $user\@$remoteHost 'powershell -command \"Get-ChildItem $wsRoot|?{\$_.name-like\\\"${appName}_*_*\\\"}|Select-Object Name\"'";
	}
	else {	
		$cmd="ssh $user\@$remoteHost \"find $wsRoot -maxdepth 1 -name '*$appName*_*' -printf '%f\\n' | sort \"";
	}
	
	my @result = $ciomUtil->execWithReturn($cmd);
	my $optionVal;
	foreach (@result) {
		$optionVal="$_";
		$optionVal =~ s/[\n|\r| ]//g;
		if ( $optionVal =~ /$appName/ ) {
			$options="<string>$optionVal</string>\n$options";
		}
		
	}
}

sub updateJobOptionsInTargetJob() {
	#echo $options
	if ( $options eq "") {
		$options="<string></string>";
	}
	$ciomUtil->execNotLogCmd("perl -i -0 -pE 's|(?<g1><name>RollbackTo</name>.*?<a class=\\\"string-array\\\">\\s+)(?<g2>.*?)(?<g3>\\s+</a>)|\$+{g1}$options\$+{g3}|sg' $jobConfigFile");
}

sub main() {
	initial();
	enterWorkspace();
	getBackupListOptions();
	updateJobOptionsInTargetJob();
	#print $options;
	leaveWorkspace();
}

main();
