#!/usr/bin/perl -W
#

use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use English;
use Data::Dumper;
use Cwd;
use CiomUtil;

my $origin = '172.17.128.210';
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

my $sparkMasters = [
	'172.17.128.210',
	'172.17.128.208',
	'172.17.128.209'
];

my $journalNodes = [
	'172.17.128.210',
	'172.17.128.208',
	'172.17.128.209'
];

my $nn1 = '172.17.128.210';
my $nn2 = '172.17.128.208';

my $hadoopConfDir = '/opt/hadoop-2.7.1/etc/hadoop';
my $sparkConfDir = '/opt/spark-1.4.0-bin-hadoop2.6/conf';
my $ciomUtil = new CiomUtil($ARGV[0] || 0);

sub cleanSyncup() {
	$ciomUtil->remoteExec({
		host => $origin,
		cmd => "rm -rf /opt/hdfsroot/name/* /opt/hdfsroot/data/* /opt/journal/data/*"
	});

	my $cnt = $#{$slaves} + 1;
	my $rsync = "rsync --delete --force -az";
	for (my $i = 0; $i < $cnt; $i++) {
		my $slave = $slaves->[$i];
		$ciomUtil->remoteExec({
			host => $origin,
			cmd => [
				"$rsync /opt/hdfsroot/* $slave:/opt/hdfsroot/",
				"$rsync /opt/journal/* $slave:/opt/journal/",
				"$rsync /etc/hosts $slave:/etc/hosts",
				"$rsync /etc/profile.d/hadoop.sh $slave:/etc/profile.d/hadoop.sh",
				"$rsync /etc/profile.d/spark.sh $slave:/etc/profile.d/spark.sh",
				"$rsync $hadoopConfDir/* $slave:$hadoopConfDir/",
				"$rsync $sparkConfDir/* $slave:$sparkConfDir/"
			]
		});
	}	
}

sub startJournalDaemons() {
	my $cnt = $#{$journalNodes} + 1;
	for (my $i = 0; $i < $cnt; $i++) {
		my $jn = $journalNodes->[$i];
		$ciomUtil->remoteExec({
			host => $jn,
			cmd => "/opt/hadoop-2.7.1/sbin/hadoop-daemon.sh start journalnode"
		});
	}	
}

sub formatNameNodes() {
	$ciomUtil->remoteExec({
		host =>  $nn1,
		cmd => "/opt/hadoop-2.7.1/bin/hdfs namenode -format"
	});
}

sub syncupNN1ToNN2() {
	$ciomUtil->remoteExec({
		host => $nn1,
		cmd => "scp -r /opt/hdfsroot/name/* $nn2:/opt/hdfsroot/name/"
	});		
}

sub initHAStateInZK() {
	$ciomUtil->remoteExec({
		host =>  $nn1,
		cmd => "/opt/hadoop-2.7.1/bin/hdfs zkfc -formatZK"
	});	
}

sub setSparkMasterIP() {
	my $cnt = $#{$sparkMasters} + 1;
	for (my $i = 0; $i < $cnt; $i++) {
		my $node = $sparkMasters->[$i];
		$ciomUtil->remoteExec({
			host => $node,
			cmd => [
				"perl -i -pE 's|(SPARK_MASTER_IP=).*|\\1$node|g' $sparkConfDir/spark-env.sh",
				"perl -i -pE 's|(spark.master\\s*spark://).*(:\\d+)|\\1$node\\2|g' $sparkConfDir/spark-defaults.conf"
			]
		});
	}	
}

sub main() {
	cleanSyncup();
	startJournalDaemons();
	formatNameNodes();
	syncupNN1ToNN2();
	initHAStateInZK();
	setSparkMasterIP();
}

main();
