#!/usr/bin/perl -W
#

use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use English;
use Data::Dumper;
use Cwd;
use CiomUtil;

my $master = '172.17.128.201';
my $slaves = [
	'172.17.128.202',
	'172.17.128.203'
];

my $zkHome = '/opt/zookeeper-3.4.6';
my $zkDataHome = '/opt/zkdata';
my $ciomUtil = new CiomUtil($ARGV[0] || 0);

sub createMyidFile($$) {
	my $host = shift;
	my $svrId = shift;

	$ciomUtil->remoteExec({
		host => $host,
		cmd => "echo $svrId > $zkDataHome/myid"
	});	
}

sub main() {
	createMyidFile($master, 1);

	my $cnt = $#{$slaves} + 1;
	my $rsync = "rsync --delete --force -az";
	for (my $i = 0; $i < $cnt; $i++) {
		my $slave = $slaves->[$i];
		$ciomUtil->remoteExec({
			host => $master,
			cmd => [
				"$rsync /etc/profile.d/zookeeper.sh $slave:/etc/profile.d/",
				"$rsync $zkHome/conf/* $slave:$zkHome/conf/",
				"$rsync $zkHome/bin/zkServer.sh $slave:$zkHome/bin/zkServer.sh",
			]
		});

		createMyidFile($slave, $i + 2);
	}
}

main();
