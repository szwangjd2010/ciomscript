#!/usr/bin/perl -W
# 
#
use strict;
use English;
use Data::Dumper;

sub main();

my $TomcatCluster = $ARGV[0];

my $Tomcats = {
	'test' => [
		{host => "192.168.0.125", 	port => "22", tomcatHome=> "/opt/test1/tomcat7-1"},
		{host => "192.168.0.125", 	port => "22", tomcatHome=> "/opt/test1/tomcat7-2"}
	],
	
	'uTomcatCluster-api' => [
		{host => "10.10.73.235", 	port => "22", tomcatParent => "/opt/ws"},
		{host => "10.10.76.73", 	port => "22", tomcatParent => "/opt/ws"},
		{host => "10.10.75.138", 	port => "22", tomcatParent => "/opt/ws"}
	],

	'uTomcatCluster-admin' => [
		{host => "10.10.74.158", 	port => "22", tomcatParent => "/opt/ws2"}
	],

	'uTomcatCluster-adminapi' => [
		{host => "10.10.75.138", 	port => "22", tomcatParent => "/opt/ws1"}
	]
};

sub main() {
	my $hosts = $Tomcats->{$TomcatCluster};
	my $cnt = $#{$hosts} + 1;
	
	for (my $i = 0; $i < $cnt; $i++) {
		my $host = $hosts->[$i];
		system("$ENV{CIOM_HOME}/restart.tomcat.on.host.sh $host->{host} $host->{port} $host->{tomcatParent}");
	}
}

main()
