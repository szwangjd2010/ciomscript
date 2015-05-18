#!/usr/bin/perl -W -I /var/lib/jenkins/workspace/ciom
#

use strict;
use English;
use Data::Dumper;
use Cwd;
use CiomUtil;

my $Hosts = [
	"10.10.73.181",
	"10.10.73.235",
	"10.10.76.73",
	"10.10.75.138",
	"10.10.74.158",
	"10.10.69.210",
	"10.10.76.80",
	"10.10.69.80",
	"10.10.69.218",
	"10.10.71.137",
	"10.10.66.90",
	"10.10.80.26",
	"10.10.71.91",
	"10.10.71.70",
	"10.10.77.173",
	"10.10.65.89",
	"10.10.68.205",
	"10.10.73.166"
];

sub main() {
	my $coimUtil = new CiomUtil(0);
	my $cnt = $#{$Hosts} + 1;
	for (my $i = 0; $i < $cnt; $i++) {
		$coimUtil->log("init host - $Hosts->[$i] ... ");
		$coimUtil->log("init host - $Hosts->[$i] ... done");
	}
}

main();
