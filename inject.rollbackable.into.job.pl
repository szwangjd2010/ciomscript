#!/usr/bin/perl -W
# 
# usages:
# 1. make job rollbackable and add available rollback-items 
#   perl inject.rollbackable.into.job.pl dev.env-yxt.datav.test.lecaiapi.deploy
#   perl inject.rollbackable.into.job.pl dev.env-yxt.datav.test.lecaiapi.deploy EnbaleRollback
#
# 2. remove rollback support from job
#   perl inject.rollbackable.into.job.pl dev.env-yxt.datav.test.lecaiapi.deploy DisableRollback
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
use File::Path;
use YAML::XS qw(LoadFile DumpFile);
use String::Escape 'escape';
use open ":encoding(utf8)";
use open IN => ":encoding(utf8)", OUT => ":utf8";
use IO::Handle;
use Text::CSV::Simple;
use CiomUtil;
use String::Buffer;

STDOUT->autoflush(1);

my $JobName = $ARGV[0];
my $EnableRollback = $ARGV[1] || "EnableRollback"; #DisableRollback or EnableRollback
my $MaxRollbackEntrys = 10;

my $CiomUtil = new CiomUtil(1);
my $Timestamp = $CiomUtil->getTimestamp();
my $OldPwd = getcwd();

my $JobsHome = "/var/lib/jenkins/jobs";
my $Workspace = "${JobsHome}/.rollback";
my $JobsInfoFile = "${Workspace}/.jobs.info";
my $JobsInfo;
my $Tpl;

sub enterWorkspace() {
	mkdir($Workspace);
	chdir($Workspace) || die "can not change working directory!";
	$CiomUtil->exec("rm -rf $Workspace/*");
	$CiomUtil->exec("rm -rf $Workspace/.jobs.info*");
}

sub leaveWorkspace() {
	chdir($OldPwd);
}

sub initTpl() {
	$Tpl = Template->new({
		ABSOLUTE => 1,
		TAG_STYLE => 'outline',
		PRE_CHOMP  => 1,
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
		$ENV{CIOM_REPO_LOCAL},
		$job->{version},
		$job->{cloudId},
		$job->{appName}
	);
}

sub getJobsInfo() {
	my $parser = Text::CSV::Simple->new;
	$parser->field_map(qw/name version cloudId appName/);
	my @tmp = $parser->read_file("${JobsInfoFile}.csv");
	$JobsInfo = \@tmp;
}

sub generateJobsInfoCSV() {
	my $conditionPath = defined($JobName) && length($JobName) > 0 ? "-path '*/$JobName/*'" : '';
	$CiomUtil->exec("find -L $JobsHome -maxdepth 2 $conditionPath -name config.xml | xargs -I {} sh -c \"grep -HoP  '(?<=universal.deliver.pl).*(?=<)' '{}' >> $JobsInfoFile\"");
	my $reToCSV = sprintf('s|^%s/([^ ]+)/config\.xml:|$1|g', $JobsHome);
	$CiomUtil->exec("perl -pE '$reToCSV' $JobsInfoFile | tr ' ', ',' > ${JobsInfoFile}.csv");
}

sub generateJobsRollbackList() {
	foreach my $job (@{$JobsInfo}) {
		my $jobName = $job->{name};
		my $jobPkgLocation = getJobPackageLocation($job);
		if (! -d $jobPkgLocation) {
			next;
		}
		my $reRevisionId = '(\d+\.){2}\d{8}\+\d{6}';
		my $rollbackListFile = "${jobName}.rbl";
		$CiomUtil->exec("find $jobPkgLocation -name $job->{appName}.*.tar.gz | grep -oP '$reRevisionId' | sort -rn | head -n $MaxRollbackEntrys > $rollbackListFile");

		my @rollbackList = read_file($rollbackListFile, chomp => 1);
		$job->{rollbackList} = \@rollbackList;
	}
}

sub updateJobXml($) {
	my $job = shift;
	my $jobName = $job->{name};
	my $jobXml = "$JobsHome/$jobName/config.xml";
	my $tplFile = "$ENV{CIOM_SCRIPT_HOME}/rollback.segment.tpl";
	if ($#{ $job->{rollbackList}} == -1) {
		return;
	}

	processTemplate($tplFile, { root => {rollbackList => $job->{rollbackList}}}, "${jobName}.pds");

	my $injectBeginIndicator = "<!-- ciom auto injected begin -->";
	my $injectEndIndicator = "<!-- ciom auto injected end -->";
	my $counter = $CiomUtil->execWithReturn("grep -c '$injectBeginIndicator' $jobXml");
	if ($counter > 0) {
		$CiomUtil->exec([
			"sed -i.$Timestamp '/$injectBeginIndicator/,/$injectEndIndicator/d' $jobXml",
		]);
	}

	if ($EnableRollback eq "DisableRollback") {
		return;
	}
	$CiomUtil->exec([
		"/bin/cp -rf ${jobXml} ${jobXml}.${Timestamp}",
		"perl -pe 'if (/<scm class=\"hudson.scm.NullSCM\"\\/>/) {system(\"cat ${jobName}.pds\")}' ${jobXml} > ${jobXml}.tmp",
		"mv -f ${jobXml}.tmp ${jobXml}"
	]);

	$CiomUtil->exec([
		"sed -i '/<properties\\/>/d' ${jobXml}"
	]);
}

sub updateJobs() {
	my $jobsNameBuf = String::Buffer->new();
	foreach my $job (@{$JobsInfo}) {
		updateJobXml($job);
		$jobsNameBuf->write($job->{name} . " ");
	}

	my $jobsName = $jobsNameBuf->flush();
	$CiomUtil->reloadJenkinsJob($jobsName);
}


sub main() {
	enterWorkspace();
	
	initTpl();
	generateJobsInfoCSV();
	getJobsInfo();
	generateJobsRollbackList();
	print Dumper($JobsInfo);
	updateJobs();

	DumpFile("${JobsInfoFile}.yaml", $JobsInfo);
	leaveWorkspace();
	return 0;
}

exit main();
