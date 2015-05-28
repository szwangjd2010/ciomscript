our $version;
our $cloudId;
our $appName;

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

	my $finalPkgName = "${appMainModuleName}_android_$code.apk";
	if ($code eq "elearning" || $code eq "eschool") {
		$finalPkgName = "${appMainModuleName}_android.apk";
	}
	$ciomUtil->exec("mv -f /tmp/ciom.android/$appName/${appMainModuleName}-release.apk $ApppkgPath/$finalPkgName");
}

sub cleanAfterOrgBuild() {
	$ciomUtil->exec("rm -rf /tmp/ciom.android/$appName/*");	
}