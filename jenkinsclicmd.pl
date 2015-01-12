#!/usr/bin/perl -W
#

use strict;
use English;
use Data::Dumper;
use BashUtil;

my $job = $ARGV[0];
my $JobParameters = {
	'v2.admin.to.aliyun' => {
		'DeployToAliBack1' => 'YES',
		'Passwordv2' => 'woyaobusuv2'
	},
	'v2.api.to.aliyun' => {
		'DeployToAliApi1' => 'YES',
		'DeployToAliApi2' => 'YES',
		'Passwordv2' => 'woyaobusuv2'
	},
	'xx-api.to.production' => {
		'DeployTo50000' => 'YES',
		'DeployTo50005' => 'YES',
		'DeployTo50012' => 'YES',
		'Password' => 'woyaobusuxx'
	},
	'xx-back.to.production' => {
		'DeployTo50000' => 'YES',
		'DeployTo50005' => 'YES',
		'DeployTo50012' => 'YES',
		'Password' => 'woyaobusuxx'
	},
	'xx-api.to.test' 	=> {},
	'xx-back.to.test' 	=> {},
	'2.0-oaf' 			=> {},
	'2.0-admin' 		=> {},
	'2.0-api' 			=> {}
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
		. " -s http://192.168.0.248:8080/"
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
	
	my $util = new BashUtil(1);
	$util->exec(constructCmd());
}

main();