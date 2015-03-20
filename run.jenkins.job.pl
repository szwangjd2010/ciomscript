#!/usr/bin/perl -W -I /var/lib/jenkins/workspace/ciom
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

sub main() {
	if ($#ARGV < 0) {
		help();
		return;
	}
	
	my $util = new CiomUtil(1);
	#$util->runJenkinsJob($job, $JobParameters->{$job});
	print $util->constructJenkinsJobCmd($job, $JobParameters->{$job});
}

main();