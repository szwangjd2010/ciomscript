our $version;
our $cloudId;
our $appName;

our $ciomUtil;
our $CiomVcaHome;
our $ApppkgPath;
our $Pms;

my $SlaveVcaHome = "/Users/ciom/ciomws/$version/$cloudId/$appName";
my $SshInfo = {
	host => '172.17.127.57',
	port => '22',
	user => 'ciom'
};

sub extraPreAction() {
	clean();
}
sub extraPostAction() {}

sub fillPms() {
	$Pms->{CFBundleShortVersionString} = $ENV{CFBundleShortVersionString};
	$Pms->{CFBundleVersion} = $ENV{CFBundleVersion};
}

sub build() {
	#following all directory are remote directory
	my $cmd2Workspace = "cd $SlaveVcaHome/WebSchool";
	#fix issue - "User Interaction Is Not Allowed"
	my $cmdUnlockKeychain = "security -v unlock-keychain -p pwdasdwx /Users/ciom/Library/Keychains/login.keychain";
	#end
	my $cmdBuild = "xcodebuild -target eschool -configuration Distribution -sdk iphoneos build";
	my $outAppDirectory = "$SlaveVcaHome/WebSchool/build/Release-iphoneos/eschool.app";
	my $ipaFile = "$SlaveVcaHome/WebSchool/eschool.ipa";
	my $cmdPackage = "xcrun -sdk iphoneos PackageApplication -v $outAppDirectory -o $ipaFile";
	
	$SshInfo->{cmd} = "( $cmd2Workspace; $cmdUnlockKeychain; $cmdBuild; $cmdPackage )";
	$ciomUtil->remoteExec($SshInfo);
}

sub moveApppkgFile($) {
	my $code = $_[0];
	#sleep for fixing following issue
	#/bin/cp -rf WebSchool/eschool.ipa /var/lib/jenkins/jobs/mobile.ios-eschool/builds/37/app/eschool_ios_barcotest.ipa 
	#/bin/cp: skipping file `WebSchool/eschool.ipa', as it was replaced while being copied
	$ciomUtil->exec("sleep 5");
	$ciomUtil->exec("mv WebSchool/eschool.ipa $ApppkgPath/eschool_ios_$code.ipa");
}

sub clean() {
	$ciomUtil->exec("rm -rf WebSchool/build/*");
}