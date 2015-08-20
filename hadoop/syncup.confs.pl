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

my $hadoopConfDir = '/opt/hadoop-2.7.1/etc/hadoop';
my $sparkConfDir = '/opt/spark-1.4.0-bin-hadoop2.6/conf';
my $zooKeeperHome = '/opt/zookeeper-3.4.6';
my $ciomUtil = new CiomUtil($ARGV[0] || 0);

sub main() {
	my $cnt = $#{$slaves} + 1;
	for (my $i = 0; $i < $cnt; $i++) {
		my $slave = $slaves->[$i];
		$ciomUtil->remoteExec({
			host => $master,
			cmd => [
				"rsync -az /etc/profile.d/hadoop.sh $slave:/etc/profile.d/hadoop.sh",
				"rsync -az /etc/profile.d/spark.sh $slave:/etc/profile.d/spark.sh",
				"rsync -az $hadoopConfDir/* $slave:$hadoopConfDir/",
				"rsync -az $sparkConfDir/* $slave:$sparkConfDir/",			
				"rsync -az $zooKeeperHome $slave:/opt/"
			]
		});
	}
}

main();
