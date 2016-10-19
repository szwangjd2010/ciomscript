#!/usr/bin/perl -W
# 
#
use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use English;
use Data::Dumper;
use Cwd;
use CiomUtil;
use JSON::Parse 'json_file_to_perl';
use JSON;
use String::Escape 'escape';
use open ":encoding(utf8)";
use open IN => ":encoding(utf8)", OUT => ":utf8";
use IO::Handle;
STDOUT->autoflush(1);

our $DistInfo = {};
our $version = $ARGV[0];
our $cloudId = $ARGV[1]; #$cloudId, should be "andriod[.*]", "ios[.*]"
our $appName = $ARGV[2];
our $orgCodes = $ARGV[3] || '*';
our $doUpload = $ENV{UploadPackage} || 'NO';

our $ciomUtil = new CiomUtil(1);
our $AppVcaHome = "$ENV{CIOM_VCA_HOME}/$version/pre/$cloudId/$appName";
our $ApppkgPath = "$ENV{JENKINS_HOME}/jobs/$ENV{JOB_NAME}/builds/$ENV{BUILD_NUMBER}/app";
our $DynamicParams = {};
our $CiomData = json_file_to_perl("$AppVcaHome/ciom.json");
our $Slave4MobileDeploy = json_file_to_perl("$ENV{CIOM_SCRIPT_HOME}/slaves4mobiledeploy.json");
our $AppCertData = json_file_to_perl("$ENV{CIOM_APPCERT_HOME}/$appName/cert.json");

my $OldPwd = getcwd();
my $NeedToBuildOrgCodes = [];


our $ExecutorInfo = [];

sub getBuildLogFile() {
	return "$ENV{JENKINS_HOME}/jobs/$ENV{JOB_NAME}/builds/$ENV{BUILD_NUMBER}/log";
}

sub getBuildError() {
	my $logFile = getBuildLogFile();
	my $buildFailedCnt = $ciomUtil->execWithReturn("grep -c 'with exit code 1' $logFile");
	return $buildFailedCnt - 1;	
}

sub writeJsonToFile($$) {
	my $data = shift;
	my $fileName = shift;  
	open my $fh, ">", $fileName;
	print $fh encode_json($data);
	close $fh;
}

sub getPlatform() {
	my $platform = '';
	if (index($cloudId, 'ios') == 0)  {
		$platform = 'ios';
	}
	if (index($cloudId, 'android') == 0)  {
		$platform = 'android';
	}

	return $platform;
}

sub enterWorkspace() {
	my $appWorkspace = "$ENV{WORKSPACE}";
	#print $appWorkspace ;
	#print "\n";
	if (! -d $appWorkspace) {
		$ciomUtil->exec("mkdir -p $appWorkspace");
	}
	chdir($appWorkspace);
}

sub leaveWorkspace() {
	chdir($OldPwd);
}

sub makeApppkgDirectory() {
	$ciomUtil->exec("mkdir $ApppkgPath");
}

#platform special#
sub constructDynamicParamsMap() {
	while ( my ($key, $value) = each(%ENV) ) {
		if ($key =~ m/^CIOMPM_(\w+)$/) {
			$DynamicParams->{$1} = $value;
		}
    }
}

sub logApppkgUrl() {
	my $url = "$ENV{BUILD_URL}/app";
	$url =~ s|:8080||;
	$url =~ s|(/\d+/)|/builds/lastStableBuild|;
	$url = $ciomUtil->prettyPath($url);
	$ciomUtil->log("\n\nbuild out packages url:");
	$ciomUtil->log($url);
	$ciomUtil->log("\n\n");
}

sub logBuildFinishedOrgs($$) {
	my $executorId = $_[0];
	my $code = $_[0];
	my $needBuildCnt = $#{$DistInfo->[$executorId]->{needToBuildOrgCodes}} + 1;

	push(@{$DistInfo->[$executorId]->{finishedBuildOrgCodes}}, $code);
	my $alreadyBuiltCnt = $#{$DistInfo->[$executorId]->{finishedBuildOrgCodes}} + 1;

	printf "On executor${executorId}, ${alreadyBuiltCnt}/${needBuildCnt} finished\n";

}

sub getNeedToBuildOrgCodes() {
	if ($orgCodes eq '*' and $cloudId eq 'android') {
		my @orgsKeys = keys %{$CiomData->{orgs}};
		$NeedToBuildOrgCodes = \@orgsKeys;
		return;
	}

	if ($orgCodes eq '*' and $cloudId eq 'ios') {
		for my $code (keys %{$CiomData->{orgs}}) {
			if ($AppCertData->{$code}->{certname} ne '') {
				push(@{$NeedToBuildOrgCodes}, $code);
			}
		}
		return;
	}

	for my $code (keys %{$CiomData->{orgs}}) {
		my $re = '(^|,)' . $code . '($|,)';
		if ($orgCodes =~ m/$re/) {
			push(@{$NeedToBuildOrgCodes}, $code);
		}
	}
}

sub validateInputOrgCodes() {
	getNeedToBuildOrgCodes();
	logNeedToBuildOrgCodes();
	return $#{$NeedToBuildOrgCodes} >= 0;
}

sub constructExecutorInfo() {
	my $platform = getPlatform();
	$ExecutorInfo = $Slave4MobileDeploy->{$platform};
}

sub calcExecutorCount() {
	my $cnt = 0;
	my $cntEx = $#$ExecutorInfo + 1;
	for (my $i=0; $i< $cntEx; $i ++) {
		$cnt += $ExecutorInfo->[$i]->{capacity};
	}
	return $cnt;
}

sub getSlaveTotalCount() {
	my $slaveCnt = $#$ExecutorInfo + 1;
	return $slaveCnt;
}

sub getCapacites($) {
	my $slaveIdx=shift;
	return $ExecutorInfo->[$slaveIdx]->{capacity};
}

sub initialDistInfo(){
	my $executorsCnt = calcExecutorCount();
	my $slavesCount = getSlaveTotalCount();
	my $totalOrgCodesCount = $#{$NeedToBuildOrgCodes} + 1 ;
	my $index = 0;

	$DistInfo->{os} = getPlatform();
	
	$DistInfo->{appName} = $appName;
	$DistInfo->{appVcaHome} = $AppVcaHome;
	$DistInfo->{doUpload} = $doUpload;
	$DistInfo->{version} = $version;
	$DistInfo->{cloudId} = $cloudId;
	$DistInfo->{dynamicParams} = $DynamicParams;

	print "$totalOrgCodesCount Orgs need to build. \n";
	print "$executorsCnt excutor(s) for building. \n";
	for (my $i=0; $i < $slavesCount; $i++) {
		my $capa = getCapacites($i);
		for (my $j=0; $j < $capa; $j++) {
			$DistInfo->{distInfo}->[$index]->{slaveid} = ${i};
			$DistInfo->{distInfo}->[$index]->{wsid} = ${j};
			$DistInfo->{distInfo}->[$index]->{workspace} = "slave${i}ws${j}";
			$index++;
		}
	}
	for (my $i=0; $i< $totalOrgCodesCount; $i++) {
		for (my $j=0; $j< $executorsCnt; $j++) {
			if ( ($i % $executorsCnt) == $j ) {
    			my $code = $NeedToBuildOrgCodes->[$i];
    			push(@{$DistInfo->{distInfo}->[$j]->{needToBuildOrgCodes}},$code);
    		}
		}
	}

	$ciomUtil->writeToFile("DistInfo.log", "ExecutorInfo as below: \n");
	$ciomUtil->appendToFile("DistInfo.log", Dumper($DistInfo));
	writeJsonToFile($DistInfo,"DistInfo.json");
}

sub logNeedToBuildOrgCodes() {
	$ciomUtil->log(Dumper($NeedToBuildOrgCodes));
}

sub logNeedToBuildOrgCodes4Executor($) {
	my $executorIdx = $_[0];
	my $ws = $DistInfo->{distInfo}->[$executorIdx]->{workspace};
	printf "Below orgs need to build for ${ws} \n";
	$ciomUtil->log(Dumper($DistInfo->{distInfo}->[$executorIdx]->{needToBuildOrgCodes}));
}

sub main() {
	my @childs;
	if (!validateInputOrgCodes()) {
		$ciomUtil->log("\n\nbuild error: org code \"$orgCodes\" does not exists!\n\n");
		return 1;
	}
	
	constructDynamicParamsMap();
	constructExecutorInfo();
	initialDistInfo();
	makeApppkgDirectory();

	my $executorsCnt = $#{$DistInfo->{distInfo}} + 1;
	for (my $i=0; $i < $executorsCnt; $i++) {
		if ( $#{$DistInfo->{distInfo}->[$i]->{needToBuildOrgCodes}} == -1){
			my $ws = $DistInfo->{distInfo}->[$i]->{workspace};
			print "No OrgCodes assigned for ${ws} \n";
			next;
		}

		logNeedToBuildOrgCodes4Executor($i);
		
		my $pid = fork();
		if (!defined($pid)) {
        	print "Error in fork: $!";
        	exit 1;
    	}
                                  
    	if ($pid == 0) {     
    		#print "Child $i$j : My pid = $$\n";
			#print "building for executor$i\n";
			#$ciomUtil->exec("$ENV{CIOM_SCRIPT_HOME}/deploy.mobile.app.multi.pl $i");
        	#print "Child $i$j : end\n";
        	exit 0;
        }
        else {
        	#print "push $$ \n";
        	push(@childs, $pid);
        }

    	sleep(1);
	}

	foreach (@childs) {
		my $tmp = waitpid($_, 0);
       	#print "done with pid $tmp\n";
	}
	
	logApppkgUrl();

	return getBuildError();
}

exit main();
