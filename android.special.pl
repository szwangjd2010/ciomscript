our $ciomUtil;
our $CiomVcaHome;
our $ApppkgPath;
our $Pms;

sub extraPreAction() {}
sub extraPostAction() {}

sub fillPms() {
	$Pms->{versionCode} = $ENV{versionCode};
	$Pms->{versionName} = $ENV{versionName};
}

sub build() {
	$ciomUtil->exec("ant -f Eschool/build.xml clean release");
}

sub moveApppkgFile($) {
	my $code = $_[0];
	$ciomUtil->exec("/bin/cp -rf /tmp/ciom.android/Elearning-release.apk $ApppkgPath/eschool_android_$code.apk");
}

sub clean() {
	$ciomUtil->exec("rm -rf /tmp/ciom.android/*");
}

sub replaceOrgCustomizedFiles($) {
	my $code = $_[0];

	my $orgCustomizedHome = "$CiomVcaHome/resource/$code/Eschool";
	$ciomUtil->exec("/bin/cp -rf $orgCustomizedHome/* Eschool/");
}