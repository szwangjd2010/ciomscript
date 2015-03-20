#!/usr/bin/perl -W -I /var/lib/jenkins/workspace/ciom
# 
#
use strict;
use English;
use Data::Dumper;

sub main();


my $Ports = {
	back => 50002,
	wu2xiaoxin => 50003,
	api1 => 50004,
	api2 => 50005,
	elife => 50006
};

sub main() {
	for my $key (keys %{$Ports}) {
		if ($ENV{$key} eq "YES") {
			system("$ENV{JENKINS_HOME}/workspace/ciom/restart.tomcat.on.host.sh 122.193.22.133 $Ports->{$key} /opt");
		}
	}
}

main()
