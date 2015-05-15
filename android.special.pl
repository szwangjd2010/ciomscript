

our $ciomUtil;
our $Ciom_VCA_Home;
our $ApppkgPath;
our $Pms;

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

	my $orgCustomizedHome = "$Ciom_VCA_Home/resource/$code/Eschool";
	$ciomUtil->exec("/bin/cp -rf $orgCustomizedHome/* Eschool/");
}