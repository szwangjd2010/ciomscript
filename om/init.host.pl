#!/usr/bin/perl -W
#

use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use English;
use Data::Dumper;
use Cwd;
use CiomUtil;

my $host = $ARGV[0];
my $port = $ARGV[1] || 22;
my $jdkver = $ARGV[2] || '1.7';
my $MAX_OPEN_FILES = 102400;

my $ciomUtil = new CiomUtil(1);

sub setMaxOpenFile() {
	$ciomUtil->exec("scp $ENV{CIOM_SCRIPT_HOME}/om/set.max.open.file.sh $host:/root/");
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
			rpmfile => 'jdk-8u91-linux-x64.rpm',
			securityLocation => '/usr/java/jdk1.8.0_91/jre/lib/security/'
		}
	};

	my $rpmfile = $JdkInfo->{$ver}->{rpmfile};
	my $securityLocation = $JdkInfo->{$ver}->{securityLocation};
	$ciomUtil->exec("scp $ENV{CIOM_REPOS_HOME}/$rpmfile $host:/root/");
	$ciomUtil->remoteExec({
		host => $host,
		cmd => "rpm -ivh /root/$rpmfile"
	});

	$ciomUtil->exec("scp $ENV{CIOM_REPOS_HOME}/jdk.patch/$ver/local_policy.jar $host:/$securityLocation");
	$ciomUtil->exec("scp $ENV{CIOM_REPOS_HOME}/jdk.patch/$ver/US_export_policy.jar $host:/$securityLocation");
	$ciomUtil->exec("scp $ENV{CIOM_REPOS_HOME}/jdk.sh $host:/etc/profile.d/");
}

sub main() {
	setMaxOpenFile();
	installJdk($jdkver);
}

main();


