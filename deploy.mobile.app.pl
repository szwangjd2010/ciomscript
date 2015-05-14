#!/usr/bin/perl -W -I /var/lib/jenkins/workspace/ciom
# 
#
use strict;
use English;
use Data::Dumper;
use Cwd;
use CiomUtil;
use JSON::Parse 'json_file_to_perl';
use String::Escape 'escape';
use open ":encoding(utf8)";
use open IN => ":encoding(utf8)", OUT => ":utf8";

my $version = $ARGV[0];
my $cloudId = $ARGV[1];
my $appName = $ARGV[2];
my $orgCodes = $ARGV[3] || '*';

our $ciomUtil = new CiomUtil(1);
our $Ciom_VCA_Home = "$ENV{JENKINS_HOME}/workspace/ver.env.specific/$version/pre/$cloudId/$appName";
our $ApppkgPath = "$ENV{JENKINS_HOME}/jobs/$ENV{JOB_NAME}/builds/$ENV{BUILD_NUMBER}/app";

require 'android.special.pl';

my $OldPwd = getcwd();
my $CiomData = json_file_to_perl("$Ciom_VCA_Home/ciom.json");

sub enterWorkspace();
sub leaveWorkspace();
sub handleOrgs();
sub checkout();
sub replaceOrgCustomizedFiles($);
sub streameditOrgConfs($);
sub streamedit4All();
sub streamedit($);
sub moveApppkgFile($);
sub makeApppkgDirectory();
sub outputApppkgUrl();
sub build();
sub clean();
sub main();

sub enterWorkspace() {
	my $appWorkspace = $ENV{WORKSPACE} || "/var/lib/jenkins/workspace/mobile.android-eschool";
	chdir($appWorkspace);
}

sub leaveWorkspace() {
	chdir($OldPwd);
}

sub makeApppkgDirectory() {
	$ciomUtil->exec("mkdir $ApppkgPath");
}

sub handleOrgs() {
	my $orgs = $CiomData->{orgs};
	for my $code (keys %{$orgs}) {
		my $re = '(^|,)' . $code . '($|,)';
		if ($orgCodes eq '*' || $orgCodes =~ m/$re/) {
			replaceOrgCustomizedFiles($code);
			streameditOrgConfs($code);
			build();
			moveApppkgFile($code);
			clean();
		}
	}	
}

sub build() {
	$ciomUtil->exec("ant -f Eschool/build.xml clean release");
}

sub moveApppkgFile($) {
	my $code = $_[0];
	$ciomUtil->exec("/bin/cp -rf /tmp/ciom.android/Elearning-release.apk $ApppkgPath/eschool_android_$code.apk");
}

sub clean() {
	$ciomUtil->exec("rm -rf /tmp/ciom.android/*");
}

sub replaceOrgCustomizedFiles($) {
	my $code = $_[0];

	my $orgCustomizedHome = "$Ciom_VCA_Home/resource/$code/Eschool";
	$ciomUtil->exec("/bin/cp -rf $orgCustomizedHome/* Eschool/");
}

sub checkout() {
	my $repos = $CiomData->{scm}->{repos};
	my $username = $CiomData->{scm}->{username};
	my $password = $CiomData->{scm}->{password};
	my $cnt = $#{$repos} + 1;

	my $cmdSvnPrefix = "svn --non-interactive --username $username --password '$password'";
	for (my $i = 0; $i < $cnt; $i++) {
		my $name = $repos->[$i]->{name};
		my $url = $repos->[$i]->{url};

		if (! -d $name) {
			$ciomUtil->exec("$cmdSvnPrefix co $url $name");
		} else {
			$ciomUtil->exec("$cmdSvnPrefix revert -R $name");
			$ciomUtil->exec("$cmdSvnPrefix update $name");
		}
	}
}

sub streamedit($) {
	my $items = $_[0];

	my $cmds = "";
	my $CmdStreameditTpl = "perl -CSDL -i -pE 's|%s|%s|mg' %s";
	for my $file (keys %{$items}) {
		my $v = $items->{$file};
		my $cnt = $#{$v} + 1;
		
		for (my $i = 0; $i < $cnt; $i++) {
			$cmds .= sprintf($CmdStreameditTpl, 
				$v->[$i]->{re},
				$v->[$i]->{to},
				$file
			);
			$cmds .= "\n";
		}
	}

	my $fileSE = "streamedit.ciom";	
	$ciomUtil->write("$fileSE", $cmds);
	$ciomUtil->exec("bash $fileSE");
	$ciomUtil->exec("cat $fileSE", 1);
}

sub streameditOrgConfs($) {
	my $code = $_[0];
	my $streameditItems = $CiomData->{orgs}->{$code}->{streameditItems};
	streamedit($streameditItems);
}

sub streamedit4All() {
	my $streameditItems = $CiomData->{streameditItems};
	streamedit($streameditItems);
}

sub outputApppkgUrl() {
	my $url = "$ENV{BUILD_URL}/app";
	$url =~ s|:8080||;
	$url =~ s|(/\d+/)|/builds/${1}|;
	$url = $ciomUtil->prettyPath($url);
	$ciomUtil->log("\n\n$url\n\n");
}


sub main() {
	enterWorkspace();
	makeApppkgDirectory();
	checkout();
	streamedit4All();
	handleOrgs();
	outputApppkgUrl();
	leaveWorkspace();
}

main();
