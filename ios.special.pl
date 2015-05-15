our $ciomUtil;
our $CiomVcaHome;
our $ApppkgPath;
our $Pms;

sub fillPms() {
	$Pms->{CFBundleShortVersionString} = $ENV{CFBundleShortVersionString};
	$Pms->{CFBundleVersion} = $ENV{CFBundleVersion};
}

sub build() {
	$ciomUtil->log("ios build");
}

sub moveApppkgFile($) {
	my $code = $_[0];
	$ciomUtil->log("ios moveApppkgFile");
}

sub clean() {
	$ciomUtil->log("ios clean");
}

sub replaceOrgCustomizedFiles($) {
	my $code = $_[0];

	my $orgCustomizedHome = "$CiomVcaHome/resource/$code/WebSchool";
	$ciomUtil->exec("/bin/cp -rf $orgCustomizedHome/* WebSchool/");
}