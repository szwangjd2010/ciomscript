#!/usr/bin/perl -W
#

use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use English;
use Data::Dumper;
use Cwd;
use CiomUtil;

my $seed = '172.17.128.210';
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

my $hbaseMaster = '172.17.128.211';
my $hbaseRegionservers = [
	'172.17.128.212',
	'172.17.128.213',
	'172.17.128.214',
	'172.17.128.215',
	'172.17.128.216',
	'172.17.128.217',
	'172.17.128.218'	
];

my $nn1 = '172.17.128.210';
my $nn2 = '172.17.128.208';

my $hadoopConfDir = '/opt/hadoop-2.7.1/etc/hadoop';
my $sparkConfDir = '/opt/spark-1.4.0-bin-hadoop2.6/conf';
my $hbaseConfDir = '/opt/hbase-1.1.2/conf';

my $componentSyncupItems = {
	common => [
		'/etc/hosts'
	],
	hdfs => [
		'/opt/hdfsroot/'
	],
	journal => [
		'/opt/journal/'
	],
	hadoop => [
		'/etc/profile.d/hadoop.sh',
		"$hadoopConfDir/"
	],
	spark => [
		'/etc/profile.d/spark.sh',
		"$sparkConfDir/"
	]
};

my $ciomUtil = new CiomUtil($ARGV[0] || 0);

sub cleanHdfs() {
	$ciomUtil->remoteExec({
		host => $seed,
		cmd => "rm -rf /opt/hdfsroot/name/* /opt/hdfsroot/data/*"
	});
}

sub cleanJournalDaemonData() {
	$ciomUtil->remoteExec({
		host => $seed,
		cmd => "rm -rf /opt/journal/data/*"
	});	
}

sub clean() {
	cleanHdfs();
	cleanJournalDaemonData();	
}

sub syncupComponent($) {
	my $component = shift;
	my $cnt = $#{$slaves} + 1;
	my $rsync = "rsync --delete --force -az";
	for (my $i = 0; $i < $cnt; $i++) {
		my $slave = $slaves->[$i];

		my $items = $componentSyncupItems->{$component};
		for (my $j = 0; $j <= $#{$items}; $j++) {
			my $item = $items->[$j];
			$ciomUtil->remoteExec({
				host => $seed,
				cmd => "$rsync $item $slave:$item"
			});			
		}
	}
}

sub syncup() {
	#syncupComponent('common');
	#syncupComponent('hdfs');
	#syncupComponent('journal');
	syncupComponent('hadoop');
	#syncupComponent('spark');
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

sub syncupHbaseConf() {
	my $cnt = $#{$hbaseRegionservers} + 1;
	my $rsync = "rsync --delete --force -az";
	for (my $i = 0; $i < $cnt; $i++) {
		my $regionserver = $hbaseRegionservers->[$i];
		$ciomUtil->remoteExec({
			host => $hbaseMaster,
			cmd => [
				#"scp -r /opt/hbase-1.1.2 $regionserver:/opt/"
				"$rsync $hbaseConfDir/* $regionserver:$hbaseConfDir/"
			]
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

sub genSetSparkConfIpScript($$) {
	my $file = shift;
	my $node = shift;
	
	my $fileContent = "perl -i -pE 's|(SPARK_MASTER_IP=).*|\${1}$node|g' $sparkConfDir/spark-env.sh\n";
	$fileContent .= "perl -i -pE 's|(spark.master\\s*spark://).*(:\\d+)|\${1}$node\${2}|g' $sparkConfDir/spark-defaults.conf\n";
	$ciomUtil->writeToFile($file, $fileContent);	
}

sub setSparkMasterIP() {
	my $cnt = $#{$sparkMasters} + 1;
	my $tmpBashFile = "/tmp/_ciom.hadoop.tmp";
	for (my $i = 0; $i < $cnt; $i++) {
		my $node = $sparkMasters->[$i];
		genSetSparkConfIpScript($tmpBashFile, $node);
		
		$ciomUtil->exec("scp $tmpBashFile $node:/tmp/");
		$ciomUtil->remoteExec({
			host =>  $node,
			cmd => "bash $tmpBashFile"
		});			
	}	
}

sub main() {
	#clean();
	syncup();
	#startJournalDaemons();
	#formatNameNodes();
	#syncupNN1ToNN2();
	#initHAStateInZK();
	#setSparkMasterIP();

	#syncupHbaseConf();
}

main();
