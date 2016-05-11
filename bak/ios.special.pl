our $version;
our $cloudId;
our $appName;

our $ciomUtil;
our $AppVcaHome;
our $ApppkgPath;
our $CiomData;

my $AppWorkspaceOnSlave = "/Users/ciom/ciomws/$version/$cloudId/$appName";
my $BuildInfo = $CiomData->{build};

my $SshInfo = {
	host => '172.17.125.245',
	port => '22',
	user => 'ciom'
};

sub globalPreAction() {}
sub globalPostAction() {}
sub preAction() {}
sub postAction() {}

sub resyncSourceCode() {
	$ciomUtil->exec("$ENV{CIOM_SCRIPT_HOME}/syncup.to.slave.sh $version $cloudId $appName osx");
}

sub generateBuildCmd() {
	my $cmd;
	if ($BuildInfo->{type} eq 'target') {
		$cmd = sprintf("xcodebuild -target %s -configuration %s -sdk %s %s",
			$BuildInfo->{typeTargetName},
			$BuildInfo->{configuration},
			$BuildInfo->{sdk},
			$BuildInfo->{target}
		);
	} else {
		$cmd = sprintf("xcodebuild -workspace %s.xcworkspace -scheme %s -configuration %s -sdk %s %s",
			$BuildInfo->{typeTargetName},
			$BuildInfo->{typeTargetName},
			$BuildInfo->{configuration},
			$BuildInfo->{sdk},
			$BuildInfo->{target}
		);		
	}

	return $cmd;
}

sub getAppBuiltOutLocation() {
	if ($BuildInfo->{type} eq 'target') {
		return "$AppWorkspaceOnSlave/$BuildInfo->{location}/build/Release-iphoneos/$BuildInfo->{typeTargetName}.app";
	} else {
		return "$AppWorkspaceOnSlave/$BuildInfo->{location}/build/Products/Release-iphoneos/$BuildInfo->{typeTargetName}.app";
	}	
}

sub build() {
	preAction();

	resyncSourceCode();

	my $build = $CiomData->{build};
	#following all directory are remote directory
	my $cmd2Workspace = "cd $AppWorkspaceOnSlave/$BuildInfo->{location}";
	#fix issue - "User Interaction Is Not Allowed"
	my $cmdUnlockKeychain = "security -v unlock-keychain -p pwdasdwx /Users/ciom/Library/Keychains/login.keychain";
	#end
	my $cmdBuild = generateBuildCmd();
	my $outAppDirectory = getAppBuiltOutLocation();
	my $ipaFile = "$AppWorkspaceOnSlave/$BuildInfo->{location}/$BuildInfo->{typeTargetName}.ipa";
	my $cmdPackage = "xcrun -sdk iphoneos PackageApplication -v $outAppDirectory -o $ipaFile";
	
	$SshInfo->{cmd} = "( $cmd2Workspace; $cmdUnlockKeychain; $cmdBuild; $cmdPackage )";
	$ciomUtil->remoteExec($SshInfo);

	postAction();
}

sub moveApppkgFile($) {
	my $code = $_[0];

	#sleep for fixing following issue
	#/bin/cp -rf WebSchool/eschool.ipa /var/lib/jenkins/jobs/mobile.ios-eschool/builds/37/app/eschool_ios_barcotest.ipa 
	#/bin/cp: skipping file `WebSchool/eschool.ipa', as it was replaced while being copied
	$ciomUtil->exec("sleep 5");
	my $appFinalPkgName = getAppFinalPkgName($code);
	my $orgIpaFile = "$ENV{CIOM_SLAVE_OSX_WORKSPACE}/$version/$cloudId/$appName/$BuildInfo->{location}/$BuildInfo->{typeTargetName}.ipa";
	$ciomUtil->exec("mv $orgIpaFile $ApppkgPath/$appFinalPkgName");
}

sub cleanAfterOrgBuild() {
	;
}

sub getBuildError() {
	my $logFile = getBuildLogFile();
	my $buildFailedCnt = $ciomUtil->execWithReturn("grep -c 'with exit code 1' $logFile");
	return $buildFailedCnt - 1;	
}