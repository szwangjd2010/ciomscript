our $version;
our $cloudId;
our $appName;

our $ciomUtil;
our $AppVcaHome;
our $ApppkgPath;
our $CiomData;

my $BuildInfo = $CiomData->{build};

sub globalPreAction() {}
sub globalPostAction() {}
sub preAction() {}
sub postAction() {}

sub build() {
	preAction();
	
	if ($BuildInfo->{builder} eq 'ant') {
		logBuildingStatus(0,"=== Start remote execute build with ant ===");
		$ciomUtil->exec("ant -f $BuildInfo->{location}/$BuildInfo->{file} $BuildInfo->{target}");
		logBuildingStatus(0,"=== end remote execute build with ant ===");
		return;
	}

	if ($BuildInfo->{builder} eq 'gradle') {
		logBuildingStatus(0,"=== Start remote execute build with gradle ===");
		$ciomUtil->exec("gradle -b $BuildInfo->{location}/$BuildInfo->{file} $BuildInfo->{target}");
		logBuildingStatus(0,"=== end remote execute build with gradle ===");
		return;
	}
	
	postAction();
}

sub moveApppkgFile($) {
	my $code = $_[0];
	printf $code;
	my $appFinalPkgName = getAppFinalPkgName($code);
	my $builtApkFile;
	if ($BuildInfo->{builder} eq 'ant') {
		$builtApkFile = "/tmp/ciom.android/$appName/$BuildInfo->{location}-release.apk";
	} else {
		$builtApkFile = "$BuildInfo->{location}/build/outputs/apk/$BuildInfo->{packagePrefix}-release.apk";
	}

	$ciomUtil->exec("mv -f $builtApkFile $ApppkgPath/$appFinalPkgName");
}

sub cleanAfterOrgBuild() {
	$ciomUtil->exec("rm -rf /tmp/ciom.android/$appName/*");	
}
