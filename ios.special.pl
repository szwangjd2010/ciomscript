our $version;
our $cloudId;
our $appName;

our $ciomUtil;
our $CiomVcaHome;
our $ApppkgPath;
our $Pms;
our $CiomData;

my $SlaveVcaHome = "/Users/ciom/ciomws/$version/$cloudId/$appName";
my $appMainModuleName = getAppMainModuleName();
my $xcodeTarget = $CiomData->{scm}->{repos}->[0]->{xcodeTarget};
my $SshInfo = {
	host => '172.17.127.57',
	port => '22',
	user => 'ciom'
};

sub extraPreAction() {}
sub extraPostAction() {}

sub fillPms() {
	$Pms->{CFBundleShortVersionString} = $ENV{CFBundleShortVersionString};
	$Pms->{CFBundleVersion} = $ENV{CFBundleVersion};
}

sub build() {
	#following all directory are remote directory
	my $cmd2Workspace = "cd $SlaveVcaHome/$appMainModuleName";
	#fix issue - "User Interaction Is Not Allowed"
	my $cmdUnlockKeychain = "security -v unlock-keychain -p pwdasdwx /Users/ciom/Library/Keychains/login.keychain";
	#end
	my $cmdBuild = "xcodebuild -target $xcodeTarget -configuration Distribution -sdk iphoneos build";
	my $outAppDirectory = "$SlaveVcaHome/$appMainModuleName/build/Release-iphoneos/${xcodeTarget}.app";
	my $ipaFile = "$SlaveVcaHome/$appMainModuleName/${xcodeTarget}.ipa";
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
	$ciomUtil->exec("mv $appMainModuleName/${xcodeTarget}.ipa $ApppkgPath/$appFinalPkgName");
}

sub cleanAfterOrgBuild() {
	$ciomUtil->exec("rm -rf $appMainModuleName/build/*");
}

sub getBuildError() {
	my $logFile = getBuildLogFile();
	my $buildFailedCnt = $ciomUtil->execWithReturn("grep -c 'BUILD FAILED' $logFile");
	return 0;	
}