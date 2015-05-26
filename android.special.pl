our $ciomUtil;
our $CiomVcaHome;
our $ApppkgPath;
our $Pms;

sub extraPreAction() {
	clean();
}
sub extraPostAction() {}

sub fillPms() {
	$Pms->{versionCode} = $ENV{versionCode};
	$Pms->{versionName} = $ENV{versionName};
}

sub build() {
	my $fileBuildXml = getAppPrimaryModuleName() . "/build.xml";
	$ciomUtil->exec("ant -f $fileBuildXml clean release");
}

sub moveApppkgFile($) {
	my $code = $_[0];
	my $appPrimaryModuleName = getAppPrimaryModuleName();
	$ciomUtil->exec("/bin/cp -f /tmp/ciom.android/$appPrimaryModuleName-release.apk $ApppkgPath/$appPrimaryModuleName_android_$code.apk");
}

sub clean() {
	$ciomUtil->exec("rm -rf /tmp/ciom.android/$appPrimaryModuleName*");
}