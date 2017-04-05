#!/usr/bin/perl -W
#

use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use English;
use Data::Dumper;
use Cwd;
use CiomUtil;
use JSON::Parse 'json_file_to_perl';

my $ciomUtil = new CiomUtil(1);
my $OldPwd = getcwd();

my $JobJsonFile="$ENV{CIOM_SCRIPT_HOME}/mrollback/jobs.json";
our $CiomData = json_file_to_perl("$JobJsonFile");

sub batchUpdate() {
	for my $job (keys %{$CiomData}) {
		my $version = $CiomData->{$job}->{version};
		my $cloudId = $CiomData->{$job}->{cloudId};
		my $appName = $CiomData->{$job}->{appName};
		#printf "$job:$version,$cloudId,$appName\n";

		my $updateJobConfigScript = "$ENV{CIOM_SCRIPT_HOME}/mrollback/update.backuplist.in.jobconfig.pl";
		my $cmd = sprintf("%s %s %s %s %s",
					$updateJobConfigScript,
					$version,
					$cloudId,
					$appName,
					$job
		);
		
		$ciomUtil->exec($cmd);
	}
}

sub reloadJenkinsConfiguration() {
	$ciomUtil->exec("java -jar $ENV{JENKINS_HOME}/jenkins-cli.jar -s http://localhost:8080/ reload-configuration");

}

sub main() {
	batchUpdate;
	reloadJenkinsConfiguration();
}

main();

