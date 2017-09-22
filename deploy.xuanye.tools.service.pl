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

my $ciomUtil = new CiomUtil(1);
my $OldPwd = getcwd();

my $AppCiomFile="$ENV{CIOM_VCA_HOME}/$version/pre/$cloudId/$appName.ciom";
require $AppCiomFile;
our $Cloud;

my $SshInfo = {
	port => '22',
	user => 'root'
};

sub enterWorkspace() {
	;
}

sub leaveWorkspace() {
	chdir($OldPwd);
}

sub getSvcJarname() {

}

sub copyJarToTarget() {
	my $host = shift;
	my $path = shift;
	my $svcjarname = shift;
	$SshInfo->{cmd} = "mkdir -p $path";
	$SshInfo->{host} = $host;
	$ciomUtil->remoteExec($SshInfo);
	my $targetJarWithFullPath = $ciomUtil->execWithReturn("find $ENV{M2_REPO_HOME} -name \"$svcjarname.jar\"");
	my $cmd="scp -r $targetJarWithFullPath root@$host:$path";
	$ciomUtil->exec($cmd);
}

sub startSvcs($$) {
	my $host = shift;
	my $svcPorts = shift;
	my $cnt = $#{$svcPorts} + 1;
	for(my $i = 0; $i < $cnt; $i++) {
		my $svcport = $svcPorts->[$i]->{port};
		$SshInfo->{cmd} = "nohup java -jar $Cloud->{targetPath}/$Cloud->{svcJarName}.jar --server.port=$svcport >/dev/null 2>&1 &";
		$SshInfo->{host} = $host;
		$ciomUtil->remoteExec($SshInfo);
	}
}

sub killSvcs($$) {
	my $host = shift;
	my $svcPorts = shift;
	my $cnt = $#{$svcPorts} + 1;
	for(my $i = 0; $i < $cnt; $i++) {
		my $svcport = $svcPorts->[$i]->{port};
		my $command = "netstat -nlp| grep $svcport| awk '{print \$7}'| awk -F\"/\" '{print \$1}'| xargs kill -9";
		my $cmd = "ssh $SshInfo->{user}\@$host \"$command\"";
		$ciomUtil->exec($cmd);
	}
}

sub deploy() {
	my $shDeploy2Host = "$ENV{CIOM_SCRIPT_HOME}/xuanye.deploy.jar.svc.sh";

	my $hosts = $Cloud->{hosts};
	my $cnt = $#{$hosts} + 1;
	for (my $i = 0; $i < $cnt; $i++) {
		
		killSvcs($hosts->[$i]->{ip},$hosts->[$i]->{svcPorts});

		my $cmd = sprintf("%s %s %s %s %s %s",
			$shDeploy2Host,
			$hosts->[$i]->{ip},
			$Cloud->{targetPath},
			$Cloud->{svcJarName},
			$Cloud->{logFullpath}
		);
		$ciomUtil->exec($cmd);

		startSvcs($hosts->[$i]->{ip},$hosts->[$i]->{svcPorts});
	}
}

sub main() {
	enterWorkspace();
	deploy();
	leaveWorkspace();
}

main();
