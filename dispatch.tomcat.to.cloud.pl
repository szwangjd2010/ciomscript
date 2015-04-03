#!/usr/bin/perl -W -I /var/lib/jenkins/workspace/ciom
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
	dev_yxtadmin => {
		tomcatParent => "/opt",
		tomcatAmount => 3,
		basePortDelta => 0,
		fileJavaOptsTpl => "tomcat.catalina.java.opts-1.tpl",
		fileHttpListenTpl => "tomcat.server.xml.http.section-1.tpl",		
		hosts => [
			{host => "172.17.128.234", 	port => "22"}
		]
	},

	ucloud => {
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
	$ciomUtil->exec(sprintf("%s %s %s %s %s",
		"$ENV{CIOM_HOME}/generate.tomcat.instance.sh",
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
