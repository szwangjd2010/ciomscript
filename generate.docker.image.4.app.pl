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
my $DockerFile="$ENV{CIOM_VCA_HOME}/$version/pre/$cloudId/$appName/Dockerfile";
my $AppPackageFile="$appName.war";
my $baseContainerName="yxt_base_$appName";
my $webappsParent = "$Cloud->{dockerWs}/$appName";
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

sub dispatchAppToTomcatHost() {
	my $deployApp = "$ENV{CIOM_SCRIPT_HOME}/deploy.app.to.docker.host.sh";
	
	my $cmd = sprintf("%s %s %s %s %s %s",
		$deployApp,
		$Cloud->{dockerHost},
		22,
		$webappsParent,
		$appName,
		$asRoot
	);

	$ciomUtil->exec($cmd);
}

sub uploadDockerfile() {
	$ciomUtil->upload($DockerFile,"$Cloud->{dockerHost}:$webappsParent");
}

sub startContainerFromBaseImage(){
	$SshInfo->{cmd} = "docker run -idt --name=$baseContainerName $Cloud->{baseImage} /bin/bash"; 
	$ciomUtil->remoteExec($SshInfo);
}

sub copyWebappsToContainer(){
	my $getContainerIdCmd = "cid=\$\(docker inspect -f \'\{\{.Id\}\}\' $baseContainerName\)";
	my $dockerRootfs = "/var/lib/docker/devicemapper/mnt/\$cid/rootfs/data/ws-1/webapps";
	my $copyWebappsCmd = "";
	if ( $asRoot eq 'ROOT'){
		$copyWebappsCmd = "cp -r $webappsParent/webapps/ROOT $dockerRootfs/";
	} else {
		$copyWebappsCmd = "cp -r $webappsParent/webapps/$appName $dockerRootfs/";
	}
	$SshInfo->{cmd} = "( $getContainerIdCmd; $copyWebappsCmd)"; 
	$ciomUtil->remoteExec($SshInfo);
	#$ciomUtil->exec("echo \$\_");
}

sub createAppImageWithDockerfile(){
	$SshInfo->{cmd} = "(cd $webappsParent; docker build -t $Cloud->{appImage} .)";
	$ciomUtil->remoteExec($SshInfo);
}

sub commitAppImage() {
	#$SshInfo->{cmd} = "(docker commit $baseContainerName $Cloud->{appImage}; docker push $Cloud->{appImage})";
	$SshInfo->{cmd} = "docker push $Cloud->{appImage}";
	$ciomUtil->remoteExec($SshInfo);
}

sub stopContainerFromBaseImage(){
	$SshInfo->{cmd} = "(docker stop $baseContainerName ; docker rm $baseContainerName)"; 
	$ciomUtil->remoteExec($SshInfo);
}

sub cleanUselessImages(){
	# not use remoteExec because of the single quote mark issue
	my $cmd="ssh -p $SshInfo->{port} $SshInfo->{user}\@$SshInfo->{host} \"docker images | grep none | awk '{print \\\$3}' | xargs docker rmi\"";
	$ciomUtil->exec($cmd);
}

sub main() {
	#enterWorkspace();
	dispatchAppToTomcatHost();
	uploadDockerfile();
	##startContainerFromBaseImage();
	##copyWebappsToContainer();
	createAppImageWithDockerfile();
	commitAppImage();
	##stopContainerFromBaseImage();
	cleanUselessImages();
	##leaveWorkspace();
}

main();
