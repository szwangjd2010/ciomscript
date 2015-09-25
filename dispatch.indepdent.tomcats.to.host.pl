#!/usr/bin/perl -W
# 
#
use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use English;
use Data::Dumper;
use Cwd;
use CiomUtil;

my $host = $ARGV[0];
my $port = $ARGV[1];
my $tomcatParentBase = $ARGV[2];
my $tomcatSeed = $ARGV[3];
my $tomcatAmount = $ARGV[4];
my $fileJavaOptsTpl = $ARGV[5] || "tomcat.catalina.java.opts.tpl";
my $fileHttpListenTpl = $ARGV[6] || "tomcat.server.xml.http.section.tpl";

my $ciomUtil = new CiomUtil(1);
my $OldPwd = getcwd();

sub usage() {
	print <<EOF;
usage:
$0 172.17.128.225 22 /data tomcat7 4 tomcat.catalina.java.opts-1.tpl  tomcat.server.xml.http.section-1.tpl
$0 172.17.128.225 22 /data tomcat7 4 tomcat.catalina.java.opts.tpl  tomcat.server.xml.http.section.tpl
$0 172.17.128.225 22 /data tomcat7 4

EOF
}

sub generateTomcatInstances($) {
	my $basePortDelta = shift;
	$ciomUtil->exec(sprintf("%s %s %s %s %s %s",
		"$ENV{CIOM_SCRIPT_HOME}/generate.tomcat.instance.sh",
		$tomcatSeed,
		1,
		$basePortDelta,
		1,
		$fileJavaOptsTpl,
		$fileHttpListenTpl
	));
}

sub dispatch($) {
	my $tomcatParent = shift;
	$ciomUtil->exec(sprintf("%s %s %s %s",
		"$ENV{CIOM_SCRIPT_HOME}/dispatch.tomcat.to.host.sh",
		$host,
		$port,
		$tomcatParent
	));
}

sub main() {
	if ($#{ARGV} < 0) {
		usage();
		return 0;
	}

	for (my $i = 0; $i < $tomcatAmount; $i++) {
		generateTomcatInstances($i);
		my $tomcatParent = "/$tomcatParentBase/ws-" . ($i + 1);
		dispatch($tomcatParent);
	}
}

main();
