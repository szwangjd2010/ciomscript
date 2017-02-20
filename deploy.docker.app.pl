#!/usr/bin/perl -W
#

use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use English;
use Data::Dumper;
use Cwd;
use CiomUtil;

my $version = $ARGV[0];
my $cloudId = $ARGV[1];
my $appName = $ARGV[2];
my $asRoot = $ARGV[3] || 'NotAsRoot';

my $ciomUtil = new CiomUtil(1);
my $OldPwd = getcwd();

my $AppCiomFile="$ENV{CIOM_VCA_HOME}/$version/pre/$cloudId/$appName.ciom";
require $AppCiomFile;
our $Cloud;
#my $MyWorkspace="$ENV{WORKSPACE}/$appName/target";
my $AppPackageFile="$appName.war";
my $baseContainerName="yxt_base_$appName";
my $appImageName="yxt_$appName";
my $tomcatBinParent = "$Cloud->{tomcatRoot}/bin";
my $tomcatLogsParent = "$Cloud->{tomcatRoot}/logs";
my $SshInfo = {
	port => '22',
	user => 'root'
};
$SshInfo->{host} = $Cloud->{dockerHost};

sub enterWorkspace() {
#	chdir($MyWorkspace);
}

sub leaveWorkspace() {
	chdir($OldPwd);
}
sub deploy() {
	my $hosts = $Cloud->{hosts};
	my $cnt = $#{$hosts} + 1;
	for (my $i = 0; $i < $cnt; $i++) {
		my $pullAppImageCmd = "docker pull $Cloud->{appImage}";
		my $stopContainerCmd = "docker stop $appName-$i";
		my $removeContainerCmd = "docker rm $appName-$i";
		my $startContanierCmd = "docker run -idt --name=$appName-$i -p $hosts->[$i]->{port}:8080 -v /data/logs/$hosts->[$i]->{port}.log/:$tomcatLogsParent/  $Cloud->{appImage} /bin/sh";
		my $startTomcatCmd = "docker exec $appName-$i $tomcatBinParent/startup.sh";
		$SshInfo->{host} = $hosts->[$i]->{ip};
		$SshInfo->{cmd} = "( $pullAppImageCmd; $stopContainerCmd; $removeContainerCmd; $startContanierCmd; $startTomcatCmd )";
		$ciomUtil->remoteExec($SshInfo);
	}
}

sub main() {
	deploy();
}

main();
