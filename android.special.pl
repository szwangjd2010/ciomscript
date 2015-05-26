our $ciomUtil;
our $CiomVcaHome;
our $ApppkgPath;
our $Pms;
our $CiomData;

my $appMainModuleName = getAppMainModuleName();

sub extraPreAction() {}
sub extraPostAction() {}

sub fillPms() {
	$Pms->{versionCode} = $ENV{versionCode};
	$Pms->{versionName} = $ENV{versionName};
}

sub build() {
	my $fileBuildXml = "$appMainModuleName/build.xml";
	$ciomUtil->exec("ant -f $fileBuildXml clean release");
}

sub moveApppkgFile($) {
	my $code = $_[0];
	$ciomUtil->exec("mv -f /tmp/ciom.android/${appMainModuleName}-release.apk $ApppkgPath/${appMainModuleName}_android_$code.apk");
}

sub cleanAfterOrgBuild() {
}