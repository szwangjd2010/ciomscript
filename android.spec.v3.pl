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
	$SshInfo->{cmd} = "mkdir -p $WsRoot/$cloudId/$Ws";
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

sub initial() {
	$appWorkspaceOnSlave = "$WsRoot/$cloudId/$Ws/$appName";
	$cmdGotoAppWsOnSlave = "cd $appWorkspaceOnSlave";
	#$cmd2Workspace = "cd $appWorkspaceOnSlave/$BuildInfo->{location}";
	$SshInfo->{host} = getCiomHost();
} 

sub resyncSourceCode() {	
	logBuildingStatus(0,"=== Start sync SourceCode to android build salve$distDetail->{slaveid}, ws$distDetail->{wsid} ===");
	my $codeSrc = "$ENV{WORKSPACE}/$Ws/$appName";
	my $codeDst = "$WsRoot/$cloudId/$Ws/";
	#$ciomUtil->exec("rsync -rlptoDz --exclude .svn --exclude $BuildInfo->{location}/build --delete --force $codeSrc $SshInfo->{user}\@$SshInfo->{host}:$codeDst");
	$ciomUtil->exec("rsync -rlptoDz --exclude .svn --delete --force $codeSrc $SshInfo->{user}\@$SshInfo->{host}:$codeDst");
	logBuildingStatus(0,"=== end sync SourceCode to android build salve ===");
}

sub gradleBuild() {
	my $cmdGradleBuild = "gradle -b $BuildInfo->{location}/$BuildInfo->{file} $BuildInfo->{target}";
	#my $cmdGradleBuild = "gradle assR";
	my $cmd2Workspace = "cd $WsRoot/$cloudId/$Ws/$appName";
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

sub remoteStreamedit($) {
	my $items = $_[0];
	generateStreameditFile($items);
	instantiateDynamicParamsInStreameditFile();
	$ciomUtil->exec("scp -P $SshInfo->{port} -r $ShellStreamedit $SshInfo->{user}\@$SshInfo->{host}:$appWorkspaceOnSlave/");
	$SshInfo->{cmd} = "( $cmdGotoAppWsOnSlave; bash $ShellStreamedit)";
	$ciomUtil->remoteExec($SshInfo);
	$ciomUtil->exec("cat $ShellStreamedit");
	$ciomUtil->exec("cat $ShellStreamedit >> _streamedit.ciom.all");
}

sub remoteStreameditConfs4Org($) {
	my $code = $_[0];
	my $streameditItems = $CiomData->{orgs}->{$code}->{streameditItems};
	$ciomUtil->exec("echo '$code' >> _streamedit.ciom.all");
	logBuildingStatus(0,"=== start streameditConfs4Org ===");
	remoteStreamedit($streameditItems);
	logBuildingStatus(0,"=== end streameditConfs4Org ===");
}

sub replaceOrgCustomizedFilesToSlave($) {
	my $code = $_[0];
	my $ciomhost = getCiomHost();
	my $orgCustomizedHome = "$AppVcaHome/resource/$code";
	$ciomUtil->exec("scp -P $SshInfo->{port} -r $orgCustomizedHome/* $SshInfo->{user}\@$ciomhost:$appWorkspaceOnSlave/");
}

sub build() {
	preAction();
	#resyncSourceCode();

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
		$builtApkFile = "$WsRoot/$cloudId/$Ws/$appName/$BuildInfo->{location}/build/outputs/apk/$BuildInfo->{packagePrefix}-release.apk";
	}

	#$ciomUtil->exec("mv -f $builtApkFile $ApppkgPath/$appFinalPkgName");
	$ciomUtil->exec("date");
	$ciomUtil->exec("scp $SshInfo->{user}\@$SshInfo->{host}:$builtApkFile $ApppkgPath/$appFinalPkgName");
	$ciomUtil->exec("date");
}

sub cleanAfterOrgBuild() {
	$ciomUtil->exec("rm -rf /tmp/ciom.android/$appName/*");	
}
