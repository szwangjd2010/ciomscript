our $version;
our $cloudId;
our $appName;

our $ciomUtil;
our $AppVcaHome;
our $ApppkgPath;
our $CiomData;
our $executorIdx;
our $distDetail;

my $BuildInfo = $CiomData->{build};
my $WsRoot = $BuildInfo->{wsRoot};
my $Ws = $DistInfo->{distInfo}->[$executorIdx]->{workspace};
my $Slave4MobileDeploy = json_file_to_perl("$ENV{CIOM_SCRIPT_HOME}/slaves4mobiledeploy.json");
my $SshInfo = {
	port => '22',
	user => 'root'
};

sub globalPreAction() {}
sub globalPostAction() {}

sub preAction() {
	$SshInfo->{cmd} = "mkdir -p $WsRoot/$DistInfo->{distInfo}->[$executorIdx]->{workspace}";
	$SshInfo->{host} = getCiomHost();
	$ciomUtil->remoteExec($SshInfo);
}

sub postAction() {}

sub getCiomHost() {
	my $slaveIdx = $distDetail->{slaveid} ;
	return $Slave4MobileDeploy->{android}->[$slaveIdx]->{ip};
} 

sub getCiSlaveId($) {
	my $slaveIdx=shift;
	return $Slave4MobileDeploy->{android}->[$slaveIdx]->{ciSlaveId};
}
sub resyncSourceCode() {	
	logBuildingStatus(0,"=== Start sync SourceCode to android build salve$distDetail->{slaveid}, ws$distDetail->{wsid} ===");
	my $codeSrc = "$ENV{WORKSPACE}/$Ws/$appName";
	my $codeDst = "$WsRoot/$Ws/";
	$ciomUtil->exec("rsync -rlptoDz --exclude .svn --delete --force $codeSrc $SshInfo->{user}\@$SshInfo->{host}:$codeDst");
	logBuildingStatus(0,"=== end sync SourceCode to android build salve ===");
}

sub gradleBuild() {
	my $cmdGradleBuild = "gradle -b $BuildInfo->{location}/$BuildInfo->{file} $BuildInfo->{target}";
	my $cmd2Workspace = "cd $WsRoot/$Ws/$appName";
	$SshInfo->{cmd} = "( $cmd2Workspace; $cmdGradleBuild )";
	$SshInfo->{host} = getCiomHost();
	logBuildingStatus(0,"=== Start remote execute build with gradle ===");
	$ciomUtil->remoteExec($SshInfo);
	logBuildingStatus(0,"=== end remote execute build with gradle ===");	
}

sub antBuild() {
	# my $cmdAntBuild = "ant -f $BuildInfo->{location}/$BuildInfo->{file} $BuildInfo->{target}";
	# my $cmd2Workspace = "cd $WsRoot/$Ws/$appName";
	# $SshInfo->{cmd} = "( $cmd2Workspace; $cmdAntBuild )";
	# $SshInfo->{host} = getCiomHost();
	# logBuildingStatus(0,"=== Start remote execute build with ant ===");
	# $ciomUtil->remoteExec($SshInfo);
	# logBuildingStatus(0,"=== end remote execute build with ant ===");	
}

sub build() {
	preAction();
	resyncSourceCode();

	if ($BuildInfo->{builder} eq 'ant') {
		#gradleBuild();
		return;
	}

	if ($BuildInfo->{builder} eq 'gradle') {
		gradleBuild();
		return;
	}
	postAction();
}

sub moveApppkgFile($) {
	my $code = $_[0];
	printf $code;
	my $appFinalPkgName = getAppFinalPkgName($code);
	my $builtApkFile;
	my $host= getCiomHost();
	if ($BuildInfo->{builder} eq 'ant') {
		#$builtApkFile = "/tmp/ciom.android/$appName/$BuildInfo->{location}-release.apk";
	} else {
		$builtApkFile = "$WsRoot/$Ws/$appName/$BuildInfo->{location}/build/outputs/apk/$BuildInfo->{packagePrefix}-release.apk";
	}

	#$ciomUtil->exec("mv -f $builtApkFile $ApppkgPath/$appFinalPkgName");
	$ciomUtil->exec("scp $SshInfo->{user}\@$SshInfo->{host}:$builtApkFile $ApppkgPath/$appFinalPkgName");
}

sub cleanAfterOrgBuild() {
	$ciomUtil->exec("rm -rf /tmp/ciom.android/$appName/*");	
}
