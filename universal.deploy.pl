#!/usr/bin/perl -W
# 
#
use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use English;
use Data::Dumper;
use Cwd;
use CiomUtil;
use JSON::Parse 'json_file_to_perl';
use String::Escape 'escape';
use open ":encoding(utf8)";
use open IN => ":encoding(utf8)", OUT => ":utf8";
use IO::Handle;
STDOUT->autoflush(1);

our $version = $ARGV[0];
our $cloudId = $ARGV[1];
our $appName = $ARGV[2];
#
# appType: tomcat, static, 
#
our $appType = $ARGV[3] || "tomcat";

our $ciomUtil = new CiomUtil(1);
our $AppVcaHome = "$ENV{CIOM_VCA_HOME}/$version/pre/$cloudId/$appName";
our $CiomData = json_file_to_perl("$AppVcaHome/ciom.json");

my $ShellStreamedit = "_streamedit.ciom";
my $OldPwd = getcwd();

sub getAppMainModuleName() {
	return $CiomData->{scm}->{repos}->[0]->{name};
}

sub getBuildLogFile() {
	return "$ENV{JENKINS_HOME}/jobs/$ENV{JOB_NAME}/builds/$ENV{BUILD_NUMBER}/log";
}

sub doAppTypeDependencyInjection() {
	require "$appType.special.pl";	
}

sub fillDynamicVariables() {
	for my $key (keys %{$CiomData->{dynamicVariables}}) {
		$CiomData->{dynamicVariables}->{$key} = $ENV{$key};
	}		
}

sub enterWorkspace() {
	my $appWorkspace = "$ENV{WORKSPACE}/$appName";
	if (! -d $appWorkspace) {
		$ciomUtil->exec("mkdir -p $appWorkspace");
	}

	chdir($appWorkspace);
}

sub leaveWorkspace() {
	chdir($OldPwd);
}

#
# placeholder for platform special
#

sub updateCode() {
	my $repos = $CiomData->{scm}->{repos};
	my $username = $CiomData->{scm}->{username};
	my $password = $CiomData->{scm}->{password};
	my $cnt = $#{$repos} + 1;

	my $cmdSvnPrefix = "svn --non-interactive --username $username --password '$password'";
	my $cmdRmUnversionedTpl = "$cmdSvnPrefix status %s | grep '^?' | awk '{print \$2}' | xargs -I{} rm -rf '{}'";
	for (my $i = 0; $i < $cnt; $i++) {
		my $name = $repos->[$i]->{name};
		my $url = $repos->[$i]->{url};

		if (! -d $name) {
			$ciomUtil->exec("$cmdSvnPrefix co $url $name");
		} else {
			$ciomUtil->execNotLogCmd(sprintf($cmdRmUnversionedTpl, $name));
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

	$ciomUtil->writeToFile("$ShellStreamedit", $cmds);
}

sub instanceDynamicVariablesInShellStreamedit() {
	my $nCiompmCnt = $ciomUtil->execWithReturn("grep -c '<ciomdv>' $ShellStreamedit");
	if ($nCiompmCnt == 0) {
		return;
	}

	for my $key (keys %{$CiomData->{dynamicVariables}}) {
		$nCiompmCnt = $ciomUtil->execWithReturn("grep -c '<ciomdv>$key</ciomdv>' $ShellStreamedit");
		if ($nCiompmCnt == 0) {
			next;
		}

		my $v = $CiomData->{dynamicVariables}->{$key};
		$ciomUtil->log("\n\ninstancing $key ...");
		$ciomUtil->exec("cat $ShellStreamedit");
		$ciomUtil->exec("perl -CSDL -i -pE 's|<ciomdv>$key</ciomdv>|$v|mg' $ShellStreamedit");
	}	
}

sub streamedit() {
	my $streameditItems = $CiomData->{streameditItems};
	generateStreameditFile($streameditItems);
	instanceDynamicVariablesInShellStreamedit();
	
	$ciomUtil->exec("bash $ShellStreamedit");
	$ciomUtil->exec("cat $ShellStreamedit");
}

sub preBuild() {
	replaceCustomiedFiles();
	streamedit();
}

sub postBuildAction() {
	;
}

sub main() {
	doAppTypeDependencyInjection();
	enterWorkspace();
	updateCode();
	fillDynamicVariables();
	preBuild();
	build();
	postBuild();
	deploy();
	leaveWorkspace();

	return getBuildError();
}

exit main();
