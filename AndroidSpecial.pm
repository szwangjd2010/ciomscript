package AndroidSpecial.pm

use strict;
use English;
use Data::Dumper;

sub new() {
    my $ciomUtil = shift;
    my $Ciom_VCA_Home = shift;
    my $ApppkgPath = shift;
	
	my $self = {
		ciomUtil => $ciomUtil,
		Ciom_VCA_Home => $Ciom_VCA_Home,
		ApppkgPath => $ApppkgPath
	};

	bless $self, $pkg;
	return $self;
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

1;
__END__