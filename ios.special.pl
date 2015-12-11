our $version;
our $cloudId;
our $appName;

our $ciomUtil;
our $AppVcaHome;
our $ApppkgPath;
our $Pms;
our $CiomData;

my $AppWorkspaceOnSlave = "/Users/ciom/ciomws/$version/$cloudId/$appName";
my $appMainModuleName = getAppMainModuleName();
my $xcodeTarget = $CiomData->{scm}->{repos}->[0]->{xcodeTarget};
my $xcodeWorkspace = $CiomData->{scm}->{repos}->[0]->{xcodeWorkspace};

if (!defined($xcodeTarget)) {
	$xcodeTarget = $xcodeWorkspace;
}

my $SshInfo = {
	host => '172.17.124.199',
	port => '22',
	user => 'ciom'
};

sub extraPreAction() {}
sub extraPostAction() {}

sub fillPms() {
	$Pms->{CFBundleShortVersionString} = $ENV{CFBundleShortVersionString};
	$Pms->{CFBundleVersion} = $ENV{CFBundleVersion};
}

sub resyncSourceCode() {
	$ciomUtil->exec("$ENV{CIOM_SCRIPT_HOME}/syncup.to.slave.sh $version $cloudId $appName osx");
}

sub build() {
	resyncSourceCode();

	#following all directory are remote directory
	my $cmd2Workspace = "cd $AppWorkspaceOnSlave/$appMainModuleName";
	#fix issue - "User Interaction Is Not Allowed"
	my $cmdUnlockKeychain = "security -v unlock-keychain -p pwdasdwx /Users/ciom/Library/Keychains/login.keychain";
	#end

	my $cmdBuild = "xcodebuild -target $xcodeTarget -configuration Distribution -sdk iphoneos build";
	if (defined($xcodeWorkspace)) {
		$cmdBuild = "xcodebuild -workspace ${xcodeWorkspace}.xcworkspace -scheme $xcodeWorkspace -configuration Release -sdk iphoneos build ARCHS='armv7 arm64' VALID_ARCHS='armv7 arm64'";
	}

	my $outAppDirectory = "$AppWorkspaceOnSlave/$appMainModuleName/build/Release-iphoneos/${xcodeTarget}.app";
	my $ipaFile = "$AppWorkspaceOnSlave/$appMainModuleName/${xcodeTarget}.ipa";
	my $cmdPackage = "xcrun -sdk iphoneos PackageApplication -v $outAppDirectory -o $ipaFile";
	
	$SshInfo->{cmd} = "( $cmd2Workspace; $cmdUnlockKeychain; $cmdBuild; $cmdPackage )";
	$ciomUtil->remoteExec($SshInfo);
}

sub getAppFinalPkgName($) {
	my $code = $_[0];
	return "$code.ipa";
}

sub moveApppkgFile($) {
	my $code = $_[0];

	#sleep for fixing following issue
	#/bin/cp -rf WebSchool/eschool.ipa /var/lib/jenkins/jobs/mobile.ios-eschool/builds/37/app/eschool_ios_barcotest.ipa 
	#/bin/cp: skipping file `WebSchool/eschool.ipa', as it was replaced while being copied
	$ciomUtil->exec("sleep 5");
	my $appFinalPkgName = getAppFinalPkgName($code);
	my $orgIpaFile = "$ENV{CIOM_SLAVE_OSX_WORKSPACE}/$version/$cloudId/$appName/$appMainModuleName/${xcodeTarget}.ipa";
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