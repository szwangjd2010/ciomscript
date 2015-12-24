our $version;
our $cloudId;
our $appName;

our $ciomUtil;
our $AppVcaHome;
our $ApppkgPath;
our $CiomData;

my $BuildInfo = $CiomData->{build};

sub extraPreAction() {}
sub extraPostAction() {}

sub build() {
	if ($BuildInfo->{builder} eq 'ant') {
		$ciomUtil->exec("ant -f $BuildInfo->{location}/$BuildInfo->{file} $BuildInfo->{target}");
		return;
	}

	if ($BuildInfo->{builder} eq 'gradle') {
		$ciomUtil->exec("gradle -b $BuildInfo->{file} $BuildInfo->{target}");
		return;
	}
}

sub getAppFinalPkgName($) {
	my $code = $_[0];
	my $pkgName = $CiomData->{orgs}->{$code}->{pkgName} || $CiomData->{pkgName};
	$pkgName =~ s|#code#|$code|;

	return "${pkgName}.apk";
}

sub moveApppkgFile($) {
	my $code = $_[0];

	my $appFinalPkgName = getAppFinalPkgName($code);
	$ciomUtil->exec("mv -f /tmp/ciom.android/$appName/$BuildInfo->{location}-release.apk $ApppkgPath/$appFinalPkgName");
}

sub cleanAfterOrgBuild() {
	$ciomUtil->exec("rm -rf /tmp/ciom.android/$appName/*");	
}

sub getBuildError() {
	my $logFile = getBuildLogFile();
	my $buildFailedCnt = $ciomUtil->execWithReturn("grep -c 'BUILD FAILED' $logFile");
	return $buildFailedCnt - 1;
}