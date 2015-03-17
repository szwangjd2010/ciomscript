#!/usr/bin/perl -W
# 
#
use strict;
use English;
use Data::Dumper;
use CiomUtil;

sub restart($$$);
sub main();

my $cloudProvider = $ARGV[0];
my $ciomUtil = new CiomUtil(1);
my $CmdTpl_KillTomcat = "pkill -9 -f '%s/'";
my $CmdTpl_StartTomcat = "export JRE_HOME='/usr/java/jdk1.7.0_76'; %s/bin/startup.sh";

my $Tomcats = {
	test => [
		{host => "192.168.0.125", 	port => "22", tomcatHome=> "/opt/test1/tomcat7-1"},
		{host => "192.168.0.125", 	port => "22", tomcatHome=> "/opt/test1/tomcat7-2"}
	],
	
	aliyun => [
		#back1
		{host => "121.41.62.20", 	port => "22", tomcatHome=> "/opt/tomcat7-1"},
		{host => "121.41.62.20", 	port => "22", tomcatHome=> "/opt/tomcat7-2"},
		{host => "121.41.62.20", 	port => "22", tomcatHome=> "/opt/tomcat7-3"},
		{host => "121.41.62.20", 	port => "22", tomcatHome=> "/opt/tomcat7-4"},
		#api1
		{host => "121.40.200.186", 	port => "22", tomcatHome=> "/opt/tomcat7-1"},
		{host => "121.40.200.186", 	port => "22", tomcatHome=> "/opt/tomcat7-2"},
		{host => "121.40.200.186", 	port => "22", tomcatHome=> "/opt/tomcat7-3"},
		{host => "121.40.200.186", 	port => "22", tomcatHome=> "/opt/tomcat7-4"},
		#api2
		{host => "121.41.37.12", 	port => "22", tomcatHome=> "/opt/tomcat7-1"},
		{host => "121.41.37.12", 	port => "22", tomcatHome=> "/opt/tomcat7-2"},
		{host => "121.41.37.12", 	port => "22", tomcatHome=> "/opt/tomcat7-3"},
		{host => "121.41.37.12", 	port => "22", tomcatHome=> "/opt/tomcat7-4"}	
	],
	
	guoke_v1 => [
		{host => "222.92.116.85", 	port => "50000", tomcatHome=> "/usr/local/tomcat7-production"},
		{host => "222.92.116.85", 	port => "50005", tomcatHome=> "/usr/local/tomcat7"},
		{host => "222.92.116.85", 	port => "50012", tomcatHome=> "/usr/local/tomcat8080"},
		{host => "222.92.116.85", 	port => "50012", tomcatHome=> "/usr/local/tomcat8081"},
		{host => "222.92.116.85", 	port => "50012", tomcatHome=> "/usr/local/tomcat8082"}		
	],
	
	guoke_v2 => [
		{host => "122.193.22.133", 	port => "50002", tomcatParent => "/opt"},
		{host => "122.193.22.133", 	port => "50003", tomcatParent => "/opt"},
		{host => "122.193.22.133", 	port => "50004", tomcatParent => "/opt"},
		{host => "122.193.22.133", 	port => "50005", tomcatParent => "/opt"},
		{host => "122.193.22.133", 	port => "50006", tomcatParent => "/opt"}
	
	]
};

sub restart($$$) {
	my $host = $_[0];
	my $port = $_[1];
	my $tomcatHome = $_[2];
	
	my $int1 = 5;
	my $int2 = 30;
	if ($ciomUtil->{RunMode} == 0) {
		$int1 = 0;
		$int2 = 0;
	}
	
	$ciomUtil->remoteExec($host, $port, sprintf($CmdTpl_KillTomcat, $tomcatHome));
	$ciomUtil->exec("sleep $int1");
	
	$ciomUtil->remoteExec($host, $port, sprintf($CmdTpl_StartTomcat, $tomcatHome));
	$ciomUtil->exec("sleep $int2");	
}

sub main() {
	my $tomcats = $Tomcats->{$cloudProvider};
	my $cnt = $#{$tomcats} + 1;
	for (my $i = 0; $i < $cnt; $i++) {
		if (defined($tomcats->[$i]->{tomcatHome})) {
			restart(
				$tomcats->[$i]->{host}, 
				$tomcats->[$i]->{port},
				$tomcats->[$i]->{tomcatHome}
			);
		}
		if (defined($tomcats->[$i]->{tomcatParent})) {
			system("$ENV{CIOM_HOME}/restart.tomcat.on.host.sh $tomcats->[$i]->{host} $tomcats->[$i]->{port} $tomcats->[$i]->{tomcatParent}");
		}		
	}
}

main()
