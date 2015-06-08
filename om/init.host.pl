#!/usr/bin/perl -W -I /var/lib/jenkins/workspace/ciom
#

use strict;
use English;
use Data::Dumper;
use Cwd;
use CiomUtil;

my $host = $ARGV[0];
my $port = $ARGV[1] || 22;
my $MAX_OPEN_FILES = 102400;

my $ciomUtil = new CiomUtil(1);

sub setMaxOpenFile() {
	$ciomUtil->exec("scp ./om/set.max.open.file.sh $host:/root/");
	$ciomUtil->remoteExec({
		host => $host,
		cmd => "bash /root/set.max.open.file.sh"
	});
}

sub installJdk($) {
	my $ver = shift;
	my $JdkInfo = {
		'1.7' =>  {
			rpmfile => 'jdk-7u76-linux-x64.rpm',
			securityLocation => '/usr/java/jdk1.7.0_76/jre/lib/security/'
		},
		'1.8' =>  {
			rpmfile => 'jdk-8u25-linux-x64.rpm',
			securityLocation => '/usr/java/jdk1.8.0_25/jre/lib/security/'
		}
	};

	my $rpmfile = $JdkInfo->{$ver}->{rpmfile};
	my $securityLocation = $JdkInfo->{$ver}->{securityLocation};
	$ciomUtil->exec("scp ./jdk/$rpmfile $host:/root/");
	$ciomUtil->remoteExec({
		host => $host,
		cmd => "rpm -ivh /root/$rpmfile"
	});

	$ciomUtil->exec("scp ./jdk/$ver/local_policy.jar $securityLocation");
	$ciomUtil->exec("scp ./jdk/$ver/US_export_policy.jar $securityLocation");
}

sub main() {
	setMaxOpenFile();
	#installJdk('1.7');
}

main();


