#!/usr/bin/perl -W
#

use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use English;
use Data::Dumper;
use Cwd;
use CiomUtil;

my $master = '172.17.128.210';
my $slaves = [
	'172.17.128.211',
	'172.17.128.212',
	'172.17.128.213',
	'172.17.128.214',
	'172.17.128.215',
	'172.17.128.216'
];
my $hadoopConfDir = '/opt/hadoop-2.7.1';
my $ciomUtil = new CiomUtil(1);

sub main() {
	my $cnt = $#{$slaves} + 1;
	for (my $i = 0; $i < $cnt; $i++) {
		$ciomUtil->remoteExec(
			$master,
			22,
			'root',
			"rsync $hadoopConfDir/* $slaves->[$i]:$hadoopConfDir/"
		);
	}
}

main();
