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
$api =~ s/[0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12}/#uuid#/g;
print $api;