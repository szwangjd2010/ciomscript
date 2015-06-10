#!/usr/bin/perl -W -I /opt/ciom/ciom
# 
#

use strict;
use English;
use Data::Dumper;
use Cwd;
use CiomUtil;

my $cloudId = $ARGV[0];
my $ciomUtil = new CiomUtil(1);
my $OldPwd = getcwd();

my $Clouds = {
	'dev-221-4' => {
		tomcatSeed => 'tomcat7',
		tomcatParent => "/opt/ws-4",
		tomcatAmount => 1,
		basePortDelta => 3,
		fileJavaOptsTpl => "tomcat.catalina.java.opts-1.tpl",
		fileHttpListenTpl => "tomcat.server.xml.http.section-1.tpl",		
		hosts => [
			{host => "172.17.128.221", 	port => "22"}
		]
	},

	'dev-234-6' => {
		tomcatSeed => 'tomcat7',
		tomcatParent => "/opt/ws-6",
		tomcatAmount => 1,
		basePortDelta => 6,
		fileJavaOptsTpl => "tomcat.catalina.java.opts-1.tpl",
		fileHttpListenTpl => "tomcat.server.xml.http.section-1.tpl",		
		hosts => [
			{host => "172.17.128.234", 	port => "22"}
		]
	},
	'dev-bvt' => {
		tomcatSeed => 'tomcat7',
		tomcatParent => "/opt/ws-3",
		tomcatAmount => 1,
		basePortDelta => 4,
		fileJavaOptsTpl => "tomcat.catalina.java.opts-1.tpl",
		fileHttpListenTpl => "tomcat.server.xml.http.section-1.tpl",		
		hosts => [
			{host => "172.17.128.232", 	port => "22"}
		]
	},	

	'ucloud' => {
		tomcatSeed => 'tomcat7',
		tomcatParent=> "/opt/ws",
		tomcatAmount => 4,
		basePortDelta => 0,
		fileJavaOptsTpl => "tomcat.catalina.java.opts.tpl",
		fileHttpListenTpl => "tomcat.server.xml.http.section.tpl",		
		hosts => [
			{host => "10.10.73.181", 	port => "50001"},
			{host => "10.10.73.181", 	port => "50002"},
			{host => "10.10.73.181", 	port => "50003"},
			{host => "10.10.73.181", 	port => "50004"}
		]
	}
};

sub generateTomcatInstances() {
	$ciomUtil->exec(sprintf("%s %s %s %s %s %s",
		"$ENV{CIOM_HOME}/ciom/generate.tomcat.instance.sh",
		$Clouds->{$cloudId}->{tomcatSeed},
		$Clouds->{$cloudId}->{tomcatAmount},
		$Clouds->{$cloudId}->{basePortDelta},
		$Clouds->{$cloudId}->{fileJavaOptsTpl},
		$Clouds->{$cloudId}->{fileHttpListenTpl}
	));
}

sub dispatch() {
	my $hosts = $Clouds->{$cloudId}->{hosts};
	my $tomcatParent = $Clouds->{$cloudId}->{tomcatParent};
	my $cnt = $#{$hosts} + 1;
	for (my $i = 0; $i < $cnt; $i++) {
		my $host = $hosts->[$i];
		$ciomUtil->exec(sprintf("%s %s %s %s",
			"$ENV{CIOM_HOME}/ciom/dispatch.tomcat.to.host.sh",
			$host->{host},
			$host->{port},
			$tomcatParent
		));
	}
}

sub enterWorkspace() {
	;
}

sub leaveWorkspace() {
	chdir($OldPwd);
}

sub main() {
	enterWorkspace();
	generateTomcatInstances();
	dispatch();
	leaveWorkspace();
}

main();
