#!/usr/bin/perl -W
# 
#
package UniveralDeliver;

use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use warnings;
use English;
use Data::Dumper;
use Template;
use Cwd;
use File::Slurp;
use YAML::XS qw(LoadFile DumpFile);
use String::Escape 'escape';
use open ":encoding(utf8)";
use open IN => ":encoding(utf8)", OUT => ":utf8";
use IO::Handle;
use Text::CSV::Simple;
use CiomUtil;
STDOUT->autoflush(1);

my $JobsInfoFile = ".jobs.info";
my $JobsInfo;
my $CiomUtil = new CiomUtil(1);
my $OldPwd = getcwd();

sub enterWorkspace() {
	chdir("/var/lib/jenkins/jobs") || die "can not change working directory!";
}

sub leaveWorkspace() {
	chdir($OldPwd);
}

sub getJobPackageLocation($) {
	my $jobInfo = shift;
	return sprintf("%s/%s/%s/%s",
		$ENV{CIOM_REPO_LOCAL_PATH},
		$jobInfo->{version},
		$jobInfo->{cloudId},
		$jobInfo->{appName}
	);
}

sub getJobsInfo() {
	my $parser = Text::CSV::Simple->new;
	$parser->field_map(qw/job version cloudId appName/);
	my @tmp = $parser->read_file("${JobsInfoFile}.csv");
	$JobsInfo = \@tmp;
}

sub generateJobsInfoCSV() {
	$CiomUtil->exec("rm -f $JobsInfoFile");
	$CiomUtil->exec("find -maxdepth 2 -name config.xml | xargs -i  grep -HoP  '(?<=universal.deliver.pl).*(?=<)' {} >> $JobsInfoFile");
	my $reToCSV = 's|^\./([^ ]+)/config\.xml:|$1|g';
	$CiomUtil->exec("perl -pE '$reToCSV' $JobsInfoFile | tr ' ', ',' > ${JobsInfoFile}.csv");
}

sub generateJobsRollbackList() {
	mkdir(".jobs.rollback.list");
	
	foreach my $jobInfo (@{$JobsInfo}) {
		my $job = $jobInfo->{job};
		my $jobPkgLocation = getJobPackageLocation($jobInfo);
		my $reRevisionId = '(\d+\.){2}\d{8}\+\d{6}';
		my $rollbackListFile = ".jobs.rollback.list/${job}";
		$CiomUtil->exec("find $jobPkgLocation -name $jobInfo->{appName}.*.tar.gz | grep -oP '$reRevisionId' > $rollbackListFile");

		my @rollbackList = read_file($rollbackListFile, chomp => 1);
		$jobInfo->{rollbackList} = \@rollbackList;
	}
}

sub getJobXmlPropertiesInfo($) {
	my $job = shift;
	my $jobXml = "~jenkins/jobs/$job/config.xml";
}

sub main() {
	enterWorkspace();
	generateJobsInfoCSV();
	getJobsInfo();
	generateJobsRollbackList();
	DumpFile("jobs.info.yaml", $JobsInfo);
	leaveWorkspace();
	return 0;
}

exit main();
