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

my $JobsHome = "/var/lib/jenkins/jobs";
my $Workspace = "${JobsHome}/.rollback";
my $JobsInfoFile = ".jobs.info";
my $JobsInfo;
my $CiomUtil = new CiomUtil(1);
my $OldPwd = getcwd();
my $Tpl;

sub enterWorkspace() {
	mkdir($Workspace);
	chdir($Workspace) || die "can not change working directory!";
}

sub leaveWorkspace() {
	chdir($OldPwd);
}

sub initTpl() {
	$Tpl = Template->new({
		ABSOLUTE => 1,
		TAG_STYLE => 'outline',
		PRE_CHOMP  => 0,
	    POST_CHOMP => 0
	});	
}

sub processTemplate {
	my ($in, $data, $out) = @_;
	$Tpl->process($in, $data, $out) 
		|| die "Template process failed: ", $Tpl->error(), "\n";	
}

sub getJobPackageLocation($) {
	my $job = shift;
	return sprintf("%s/%s/%s/%s",
		$ENV{CIOM_REPO_LOCAL_PATH},
		$job->{version},
		$job->{cloudId},
		$job->{appName}
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
	$CiomUtil->exec("find -L $JobsHome -maxdepth 2 -name config.xml | xargs -i  grep -HoP  '(?<=universal.deliver.pl).*(?=<)' {} >> $JobsInfoFile");
	my $reToCSV = sprintf('|^%s/([^ ]+)/config\.xml:|$1|g', $JobsHome);
	$CiomUtil->exec("perl -pE '$reToCSV' $JobsInfoFile | tr ' ', ',' > ${JobsInfoFile}.csv");
}

sub generateJobsRollbackList() {
	foreach my $job (@{$JobsInfo}) {
		my $jobName = $job->{job};
		my $jobPkgLocation = getJobPackageLocation($jobName);
		my $reRevisionId = '(\d+\.){2}\d{8}\+\d{6}';
		my $rollbackListFile = "${jobName}.rbl";
		$CiomUtil->exec("find $jobPkgLocation -name $job->{appName}.*.tar.gz | grep -oP '$reRevisionId' > $rollbackListFile");

		my @rollbackList = read_file($rollbackListFile, chomp => 1);
		$job->{rollbackList} = \@rollbackList;
	}
}

sub editJobXml($) {
	my $job = shift;
	my $jobName = $job->{name};
	my $jobXml = "$JobsHome/$jobName/config.xml";
	my $tplFile = "$ENV{CIOM_SCRIPT_HOME}/rollback.segment.tpl";
	my $macthed = $CiomUtil->execWithReturn("grep -on '<properties/>' $jobXml");

	my $data = {
		parameterDefinitions => 0,
		rollbackList => $job->{rollbackList}
	};

	if ($macthed eq '<properties/>' ) {
		 $data->{parameterDefinitions} = 1;
	} else {
		# $CiomUtil->exec([
		# 	"sed '/<!-- auto injected begin - ciom rollback -->/,/<!-- auto injected end - ciom rollback -->/d' $jobXml",
		# 	"sed '/<parameterDefinitions>/r ' $jobXml",
		# ]);
	}
	processTemplate($tplFile, { root => $data}, "${jobName}.xml");
}

sub main() {
	enterWorkspace();
	initTpl();
	generateJobsInfoCSV();
	getJobsInfo();
	generateJobsRollbackList();
	DumpFile("jobs.info.yaml", $JobsInfo);

	leaveWorkspace();
	return 0;
}

exit main();
