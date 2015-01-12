#!/usr/bin/perl -W
# 
#

use strict;
use English;
use Data::Dumper;
use Cwd;
use BashUtil;

my $cloudId = $ARGV[0];
my $bashUtil = new BashUtil(1);
my $OldPwd = getcwd();

my $CloudHosts = {
	test => {
		tomcatParent => "/opt",
		tomcatAmount => 2,
		basePortDelta => 0,
		fileJavaOptsTpl => "tomcat.catalina.java.opts-1.tpl",
		fileHttpListenTpl => "tomcat.server.xml.http.section-1.tpl",		
		hosts => [
			{host => "192.168.0.125", 	port => "22"}
		]
	},
	

	aliyun_ws1 => {
		tomcatParent=> "/opt/ws1",
		tomcatAmount => 3,
		basePortDelta => 0,
		fileJavaOptsTpl => "tomcat.catalina.java.opts.tpl",
		fileHttpListenTpl => "tomcat.server.xml.http.section.tpl",		
		hosts => [
			{host => "121.41.62.20", 	port => "22"},#back
			{host => "121.40.200.186", 	port => "22"},#api1
			{host => "121.41.37.12", 	port => "22"},#api2
			{host => "121.40.202.100", 	port => "22"} #web1
		]
	},

	aliyun_ws2 => {
		tomcatParent=> "/opt/ws2",
		tomcatAmount => 1,
		basePortDelta => 10,
		fileJavaOptsTpl => "tomcat.catalina.java.opts-1.tpl",
		fileHttpListenTpl => "tomcat.server.xml.http.section-1.tpl",		
		hosts => [
			{host => "121.41.62.20", 	port => "22"},#back
			{host => "121.40.200.186", 	port => "22"},#api1
			{host => "121.41.37.12", 	port => "22"},#api2
			{host => "121.40.202.100", 	port => "22"} #web1
		]
	},

	aliyun_ws3 => {
		tomcatParent=> "/opt/ws3",
		tomcatAmount => 1,
		basePortDelta => 20,
		fileJavaOptsTpl => "tomcat.catalina.java.opts-1.tpl",
		fileHttpListenTpl => "tomcat.server.xml.http.section-1.tpl",		
		hosts => [
			{host => "121.41.62.20", 	port => "22"},#back
			{host => "121.40.200.186", 	port => "22"},#api1
			{host => "121.41.37.12", 	port => "22"},#api2
			{host => "121.40.202.100", 	port => "22"} #web1
		]
	},	

	aliyun_ws4 => {
		tomcatParent=> "/opt/ws4",
		tomcatAmount => 1,
		basePortDelta => 30,
		fileJavaOptsTpl => "tomcat.catalina.java.opts-1.tpl",
		fileHttpListenTpl => "tomcat.server.xml.http.section-1.tpl",		
		hosts => [
			{host => "121.41.62.20", 	port => "22"},#back
			{host => "121.40.200.186", 	port => "22"},#api1
			{host => "121.41.37.12", 	port => "22"},#api2
			{host => "121.40.202.100", 	port => "22"} #web1
		]
	},

	guoke => {
		tomcatParent=> "/opt",
		tomcatAmount => 4,
		basePortDelta => 0,
		fileJavaOptsTpl => "tomcat.catalina.java.opts.tpl",
		fileHttpListenTpl => "tomcat.server.xml.http.section.tpl",		
		hosts => [
			{host => "122.193.22.133", 	port => "50002"},#back
			{host => "122.193.22.133", 	port => "50003"},#52xiaoxin.api
			{host => "122.193.22.133", 	port => "50004"},#api1
			{host => "122.193.22.133", 	port => "50005"},#api2
			{host => "122.193.22.133", 	port => "50006"} #life.api
		]
	}	
};

sub generateTomcatInstances() {
	$bashUtil->exec(sprintf("%s %s %s %s %s",
		"$ENV{CIOM_HOME}/generate.tomcat.instance.sh",
		$CloudHosts->{$cloudId}->{tomcatAmount},
		$CloudHosts->{$cloudId}->{basePortDelta},
		$CloudHosts->{$cloudId}->{fileJavaOptsTpl},
		$CloudHosts->{$cloudId}->{fileHttpListenTpl}
	));
}

sub dispatch() {
	my $hosts = $CloudHosts->{$cloudId}->{hosts};
	my $tomcatParent = $CloudHosts->{$cloudId}->{tomcatParent};
	my $cnt = $#{$hosts} + 1;
	for (my $i = 0; $i < $cnt; $i++) {
		my $host = $hosts->[$i];
		$bashUtil->exec(sprintf("%s %s %s %s",
			"$ENV{CIOM_HOME}/dispatch.tomcat.to.host.sh",
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
