#!/usr/bin/perl -W
#

use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use English;
use Data::Dumper;
use Data::UUID;
use CiomUtil;
my $ug = Data::UUID->new();	

my $aa = {
	"k1" => 1,
	"k2" => 2
};

my $ciomUtil = new CiomUtil(0);
$ciomUtil->log("aaaaaaaaaaaaaaaaaaa");
my @b = (keys %{$aa});
print Dumper(\@b);


my $c=[];
print $#{[]};