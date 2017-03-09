our $version;
our $cloudId;
our $appName;

our $CiomUtil;
our $AppVcaHome;
our $CiomData;
our $AppType;

my $BuildInfo = $CiomData->{build};

sub typePreBuild() {};
sub typePostBuild() {};
sub typePreDeploy() {};
sub typePostDeploy() {};

