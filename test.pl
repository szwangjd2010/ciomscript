#!/usr/bin/perl -W
#

use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use English;
use Data::Dumper;
use Data::UUID;
use CiomUtil;
my $ug = Data::UUID->new();	

my $api = "/v1/industries/0/positionfunctions/3e74bb02-4e9d-4b50-a696-856a59cd2b78/positions";
my $orgId = "3e74bb02-4e9d-4b50-a696-856a59cd2b78";
if ($api =~ m/(\Q$orgId\E)/) {
	#print $1;
}

my $a = {
	"a" => 1, 
	"b" => 2
};

#%{$a} = ();
#undef %{$a};

print defined($a) . "\n";
$a->{c} = 3;

print "$a->{b}-release.apk";

