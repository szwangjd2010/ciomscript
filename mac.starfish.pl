our $version;
our $cloudId;
our $appName;

our $ciomUtil;
our $AppVcaHome;
our $ApppkgPath;
our $CiomData;
our $distDetail;
our $executorIdx;

my $AppWorkspaceOnSlave = "/Users/ciom/ciomws/$version/$cloudId/$appName";
my $BuildInfo = $CiomData->{build};
my $PlatformId = $CiomData->{platform}->{mac};
my $SlaveWorkspaceEnv;


my $SshInfo = {
	port => '22',
	user => 'ciom'
};

sub globalPreAction() {}
sub globalPostAction() {}

sub preAction() {
	my $pfId = uc($PlatformId);
	my $slaveWorkspaceEnvVarName = "CIOM_SLAVE_${pfId}_WORKSPACE";
	$SlaveWorkspaceEnv = "$ENV{$slaveWorkspaceEnvVarName}";
}

sub postAction() {}

sub getAppWorkspaceOnSlave(){
	return "/Users/ciom/ciomws/ws/$version/$cloudId/$appName";
}

sub getAppBuiltOutLocation() {
	return "/Users/ciom/ciomws/ws/$version/$cloudId/${appName}-release";
}

sub resyncSourceCode() {
	logBuildingStatus(0,"=== Start sync SourceCode to $PlatformId salve ===");
	$ciomUtil->exec("$ENV{CIOM_SCRIPT_HOME}/syncup.to.slave.sh $version $cloudId $appName $PlatformId");
	logBuildingStatus(0,"=== end sync SourceCode to $PlatformId salve ===");
}

sub generateBuildCmd() {
	my $cmd;
	my $appWorkspaceOnSlave = getAppWorkspaceOnSlave();
	my $outAppDirectory = getAppBuiltOutLocation();
	$cmd = sprintf("sh $CiomData->{installer}->{mac}->{script} %s %s %s %s %s %s",
		$SshInfo->{user},
		$appWorkspaceOnSlave,
		$CiomData->{installer}->{mac}->{templateLocation},
		$outAppDirectory,
		$CiomData->{builder}->{mac}->{sfCerId},
		0
	);
	
	return $cmd;
}

sub build() {
	preAction();
	resyncSourceCode();
	my $appWorkspaceOnSlave = getAppWorkspaceOnSlave();
	my $cmd2Installer = "cd $appWorkspaceOnSlave/$CiomData->{installer}->{mac}->{location}";
	my $cmdBuild = generateBuildCmd();
	#fix issue - "User Interaction Is Not Allowed"
	my $cmdUnlockKeychain = "security -v unlock-keychain -p pwdasdwx /Users/ciom/Library/Keychains/login.keychain";
	#end
	$ciomUtil->exec("echo $cmdBuild");
	$SshInfo->{host} = $CiomData->{builder}->{mac}->{ip};
	$SshInfo->{cmd} = "( $cmd2Installer; $cmdUnlockKeychain; $cmdBuild)";
	logBuildingStatus(0,"=== Start remote execute build ===");
	logBuildingStatus(0,"cmd is $SshInfo->{cmd}");
	$ciomUtil->remoteExec($SshInfo);
	logBuildingStatus(0,"=== end remote execute build ===");
	#my $outAppDirectory = getAppBuiltOutLocation();
	moveApppkgFile();
	postAction();
}

sub moveApppkgFile() {
	my $outputAppDirectory = "$SlaveWorkspaceEnv/ws/$version/$cloudId/${appName}-release";
	$ciomUtil->exec("mv $outputAppDirectory/* $ApppkgPath");
}

sub cleanAfterOrgBuild() {
	;
}



