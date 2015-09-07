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
	'172.17.128.208',
	'172.17.128.209',
	'172.17.128.211',
	'172.17.128.212',
	'172.17.128.213',
	'172.17.128.214',
	'172.17.128.215',
	'172.17.128.216',
	'172.17.128.217',
	'172.17.128.218'
];

my $hadoopConfDir = '/opt/hadoop-2.7.1/etc/hadoop';
my $sparkConfDir = '/opt/spark-1.4.0-bin-hadoop2.6/conf';
my $ciomUtil = new CiomUtil($ARGV[0] || 0);

sub main() {
	$ciomUtil->remoteExec({
		host => $master,
		cmd => "rm -rf /opt/hdfsroot/name/* /opt/hdfsroot/data/*"
	});

	my $cnt = $#{$slaves} + 1;
	my $rsync = "rsync --delete --force -az";
	for (my $i = 0; $i < $cnt; $i++) {
		my $slave = $slaves->[$i];
		$ciomUtil->remoteExec({
			host => $master,
			cmd => [
				"$rsync /opt/hdfsroot/* $slave:/opt/hdfsroot/",
				"$rsync /etc/hosts $slave:/etc/hosts",
				"$rsync /etc/profile.d/hadoop.sh $slave:/etc/profile.d/hadoop.sh",
				"$rsync /etc/profile.d/spark.sh $slave:/etc/profile.d/spark.sh",
				"$rsync $hadoopConfDir/* $slave:$hadoopConfDir/",
				"$rsync $sparkConfDir/* $slave:$sparkConfDir/"
			]
		});
	}
}

main();
