#!/usr/bin/perl -W -I /var/lib/jenkins/workspace/ciom
# 
#

use strict;
use English;
use Data::Dumper;
use Cwd;
use CiomUtil;

my $cloudId = $ARGV[0];
my $ciomUtil = new CiomUtil(0);
my $OldPwd = getcwd();

my $Job = '__dev.env-yxt.web.deploy.to.host';
my $CloudInfo = {
	dev => {
		appFile => 'C:\ciom.workspace\yxtweb.zip',
		wwwLocation => 'c:\www',
		username => 'ci',
		password => 'P@ss!23',
		hosts => [
			'172.17.128.243',
			'172.17.128.242'
		]
	}
};

sub enterWorkspace() {
	;
}

sub leaveWorkspace() {
	chdir($OldPwd);
}

sub deploy() {
	my $cloudInfo = $CloudInfo->{$cloudId};

	my $jenkinsJobParams = {
		'ciomUserName' => $cloudInfo->{username},
		'ciomUserPassword' => $cloudInfo->{password},
		'ciomAppPackageFile' => $cloudInfo->{appFile},
		'ciomAppDeployedLocation' => $cloudInfo->{wwwLocation}
	};	
	
	my $hosts = $cloudInfo->{hosts};
	my $cnt = $#{$hosts} + 1;
	for (my $i = 0; $i < $cnt; $i++) {
		$jenkinsJobParams->{ciomHost} = $hosts->[$i];
		$ciomUtil->runJenkinsJob($Job, $jenkinsJobParams);
	}
}

sub main() {
	enterWorkspace();
	deploy();
	leaveWorkspace();
}

main();
