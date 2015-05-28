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

sub getAppFinalPkgName($) {
	my $code = $_[0];
	my $prefix = $CiomData->{pkgPrefix};
	my $suffix = "$code";
	if ($code eq "elearning" || $code eq "eschool") {
		$suffix = "";
	}

	return "${prefix}_${suffix}.apk";
}

sub moveApppkgFile($) {
	my $code = $_[0];

	my $appFinalPkgName = getAppFinalPkgName($code);
	$ciomUtil->exec("mv -f /tmp/ciom.android/$appName/${appMainModuleName}-release.apk $ApppkgPath/$appFinalPkgName");
}

sub cleanAfterOrgBuild() {
	$ciomUtil->exec("rm -rf /tmp/ciom.android/$appName/*");	
}