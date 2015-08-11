#!/usr/bin/perl -W
# 
#
use lib "$ENV{CIOM_SCRIPT_HOME}";
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
	}
};

sub generateTomcatInstances() {
	$ciomUtil->exec(sprintf("%s %s %s %s %s %s",
		"$ENV{CIOM_SCRIPT_HOME}/generate.tomcat.instance.sh",
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
			"$ENV{CIOM_SCRIPT_HOME}/dispatch.tomcat.to.host.sh",
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
