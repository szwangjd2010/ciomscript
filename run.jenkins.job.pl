#!/usr/bin/perl -W
#

use strict;
use English;
use Data::Dumper;
use CiomUtil;

my $job = $ARGV[0];
my $JobParameters = {
	'__dev.env-yxt.web.deploy.to.host' => {
		'ciomHost' => '172.17.128.243',
		'ciomUserName' => 'ci',
		'ciomUserPassword' => 'P@ss!23',
		'ciomAppPackageFile' => 'C:\ciom.workspace\yxtweb.zip',
		'ciomAppDeployedLocation' => 'C:\iis'
	}
};

sub help() {
	my @jobs = keys %{$JobParameters};
	my $jobList = join("\n", @jobs);
	print <<"HELP";
usage: $0 %jobName

available jobName: 
$jobList

HELP
}

sub constructJenkinsParameters() {
	my $str = "";
	while ( my ($key, $value) = each(%{$JobParameters->{$job}}) ) {
		$str .= " -p $key=$value";
	}
	
	return $str;
}

sub constructCmd() {
	my $CmdPrefix = "java -jar /var/lib/jenkins/jenkins-cli.jar"
		. " -s http://172.17.128.240:8080/"
		. " -i /var/lib/jenkins/.ssh/id_rsa"
		. " build $job"
		. " -s -v";
		
	return $CmdPrefix . constructJenkinsParameters();
}

sub main() {
	if ($#ARGV < 0) {
		help();
		return;
	}
	
	my $util = new CiomUtil(1);
	$util->exec(constructCmd());
}

main();