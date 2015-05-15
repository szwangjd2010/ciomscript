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
our $CiomVcaHome = "$ENV{JENKINS_HOME}/workspace/ver.env.specific/$version/pre/$cloudId/$appName";
our $ApppkgPath = "$ENV{JENKINS_HOME}/jobs/$ENV{JOB_NAME}/builds/$ENV{BUILD_NUMBER}/app";
our $Pms = {};

my $ShellStreamedit = "_streamedit.ciom";
my $OldPwd = getcwd();
my $CiomData = json_file_to_perl("$CiomVcaHome/ciom.json");

require "$cloudId.special.pl";

sub enterWorkspace() {
	my $appWorkspace = $ENV{WORKSPACE} || "/var/lib/jenkins/workspace/mobile.$cloudId-eschool";
	chdir($appWorkspace);
}

sub leaveWorkspace() {
	chdir($OldPwd);
}

sub makeApppkgDirectory() {
	$ciomUtil->exec("mkdir $ApppkgPath");
}

#platform special#

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

sub generateStreameditFile($) {
	my $items = $_[0];

	my $cmds = "";
	my $CmdStreameditTpl = "perl -CSDL %s-i -pE 's|%s|%s|mg' %s";
	for my $file (keys %{$items}) {
		my $v = $items->{$file};
		my $cnt = $#{$v} + 1;
		
		for (my $i = 0; $i < $cnt; $i++) {
			my $lineMode = defined($v->[$i]->{single}) ? '-0 ' : '';
			$cmds .= sprintf($CmdStreameditTpl,
				$lineMode,
				$v->[$i]->{re},
				$v->[$i]->{to},
				$file
			);
			$cmds .= "\n";
		}
	}

	$ciomUtil->write("$ShellStreamedit", $cmds);
}

sub replacePmsInShellStreamedit() {
	for my $key (keys %{$Pms}) {
		my $nCiompmCnt = $ciomUtil->execWithReturn("grep -c '<ciompm>$key</ciompm>' $ShellStreamedit");
		if ($nCiompmCnt == 0) {
			next;
		}

		my $v = $Pms->{$key};
		$ciomUtil->log("\n\ninstantiate $key ...");
		$ciomUtil->exec("cat $ShellStreamedit", 1);
		$ciomUtil->exec("perl -CSDL -i -pE 's|<ciompm>$key</ciompm>|$v|mg' $ShellStreamedit");
	}	
}

sub streamedit($) {
	my $items = $_[0];
	generateStreameditFile($items);
	replacePmsInShellStreamedit();
	
	$ciomUtil->exec("bash $ShellStreamedit");
	$ciomUtil->exec("cat $ShellStreamedit", 1);
	$ciomUtil->exec("cat $ShellStreamedit >> _streamedit.ciom.all");
}

sub streameditOrgConfs($) {
	my $code = $_[0];
	my $streameditItems = $CiomData->{orgs}->{$code}->{streameditItems};
	$ciomUtil->exec("echo '$code' >> _streamedit.ciom.all");
	streamedit($streameditItems);
}

sub streamedit4All() {
	my $streameditItems = $CiomData->{streameditItems};
	$ciomUtil->exec("\n\n\necho '$ENV{BUILD_NUMBER} - $orgCodes' >> _streamedit.ciom.all");
	$ciomUtil->exec("echo ciom.global >> _streamedit.ciom.all");
	streamedit($streameditItems);
}

sub outputApppkgUrl() {
	my $url = "$ENV{BUILD_URL}/app";
	$url =~ s|:8080||;
	$url =~ s|(/\d+/)|/builds/${1}|;
	$url = $ciomUtil->prettyPath($url);
	$ciomUtil->log("\n\nclick to get build out packages:");
	$ciomUtil->log("<a href=\"$url\">$url</a>");
	$ciomUtil->log("\n\n");
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

sub main() {
	enterWorkspace();
	makeApppkgDirectory();
	checkout();
	fillPms();
	streamedit4All();
	handleOrgs();
	outputApppkgUrl();
	leaveWorkspace();
}

main();
