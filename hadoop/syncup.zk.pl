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
	'172.17.128.209'
];

my $zkHome = '/opt/zookeeper-3.4.6';
my $ciomUtil = new CiomUtil($ARGV[0] || 0);

sub createMyidFile($$) {
	my $host = shift;
	my $svrId = shift;

	$ciomUtil->remoteExec({
		host => $host,
		cmd => "echo $svrId > $zkHome/data/myid"
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
			cmd => "$rsync $zkHome/conf/* $slave:$zkHome/conf/"
		});

		createMyidFile($slave, $i + 2);
	}
}

main();
