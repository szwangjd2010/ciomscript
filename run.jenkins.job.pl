#!/usr/bin/perl -W
#
use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use English;
use Data::Dumper;
use CiomUtil;

my $Alias2JobName = {
	web => 'ucloud.env-yxt.web.deploy',
	api => 'ucloud.env-yxt.api.deploy',
	admin => 'ucloud.env-yxt.admin.deploy',
	adminapi => 'ucloud.env-yxt.adminapi.deploy',
};

my $JobParameters = {
	'CiomPassphrase' => 'YXTduang2015'
};

sub help() {
	my @jobs = keys %{$Alias2JobName};
	my $jobList = join("\n", @jobs);
	print <<"HELP";
usage: 
$0 %jobAlias

available alias: 
$jobList

HELP
}


sub main() {
	if ($#ARGV < 0) {
		help();
		return;
	}
	
	my $alias = $ARGV[0];
	my $job = $Alias2JobName->{$alias};
	my $util = new CiomUtil(1);

	$util->runJenkinsJob($job, $JobParameters->{$job});
	#print $util->constructJenkinsJobCmd($job, $JobParameters);
}

main();