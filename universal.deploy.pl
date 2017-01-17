#!/usr/bin/perl -W
# 
#
use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use English;
use Data::Dumper;
use Data::Diver qw( Dive DiveRef DiveError );
use Hash::Merge::Simple qw( merge );
use Cwd;
use CiomUtil;
use JSON::Parse 'json_file_to_perl';
use String::Escape 'escape';
use open ":encoding(utf8)";
use open IN => ":encoding(utf8)", OUT => ":utf8";
use IO::Handle;
STDOUT->autoflush(1);

sub getAppPkgUrl();

our $version = $ARGV[0];
our $cloudId = $ARGV[1];
our $appName = $ARGV[2];


our $CiomUtil = new CiomUtil(1);
our $AppVcaHome = "$ENV{CIOM_VCA_HOME}/$version/pre/$cloudId/$appName";
our $CiomData = json_file_to_perl("$AppVcaHome/ciom.json");
our $AppType = $CiomData->{AppType};

our $AppPkgName = "$appName.tar.gz";
our $AppPkgUrl = getAppPkgUrl();
our $Timestamp = $CiomUtil->getTimestamp();

my $ShellStreamedit = "_streamedit.ciom";
my $OldPwd = getcwd();

sub getAppMainModuleName() {
	return $CiomData->{scm}->{repos}->[0]->{name};
}

sub getBuildLogFile() {
	return "$ENV{JENKINS_HOME}/jobs/$ENV{JOB_NAME}/builds/$ENV{BUILD_NUMBER}/log";
}

sub getAppPkgUrl() {
	return sprintf("$ENV{CIOM_REPO_URL_BASE}/%s/%s/%s",
		$version,
		$cloudId,
		$AppPkgName
	);
}

sub loadPlugin() {
	my $Plugin = json_file_to_perl("$ENV{CIOM_SCRIPT_HOME}/plugins/${AppType}.ciom");
	$CiomData->{build} = merge $Plugin->{build}, $CiomData->{build};
	$CiomData->{deploy} = merge $Plugin->{deploy}, $CiomData->{deploy};
	$CiomData->{dispatch} = merge $Plugin->{dispatch}, $CiomData->{dispatch};
}

sub fillDynamicVariables() {
	for my $key (keys %{$CiomData->{dynamicVariables}}) {
		$CiomData->{dynamicVariables}->{$key} = $ENV{$key};
	}		
}

sub enterWorkspace() {
	chdir($ENV{WORKSPACE});
}

sub leaveWorkspace() {
	chdir($OldPwd);
}

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
			$CiomUtil->exec("$cmdSvnPrefix co $url $name");
		} else {
			$CiomUtil->execNotLogCmd(sprintf($cmdRmUnversionedTpl, $name));
			$CiomUtil->exec("$cmdSvnPrefix revert -R $name");
			$CiomUtil->exec("$cmdSvnPrefix update $name");
		}			
	}
}

sub replaceCustomiedFiles() {
	my $customizedFilesLocation = "$AppVcaHome/customized/";
	if ( -d $customizedFilesLocation) {
			$CiomUtil->exec("/bin/cp -rf $customizedFilesLocation ./");
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

	$CiomUtil->writeToFile("$ShellStreamedit", $cmds);
}

sub instanceDynamicVariablesInShellStreamedit() {
	my $nCiompmCnt = $CiomUtil->execWithReturn("grep -c '<ciomdv>' $ShellStreamedit");
	if ($nCiompmCnt == 0) {
		return;
	}

	for my $key (keys %{$CiomData->{dynamicVariables}}) {
		$nCiompmCnt = $CiomUtil->execWithReturn("grep -c '<ciomdv>$key</ciomdv>' $ShellStreamedit");
		if ($nCiompmCnt == 0) {
			next;
		}

		my $v = $CiomData->{dynamicVariables}->{$key};
		$CiomUtil->log("\n\ninstancing $key ...");
		$CiomUtil->exec("cat $ShellStreamedit");
		$CiomUtil->exec("perl -CSDL -i -pE 's|<ciomdv>$key</ciomdv>|$v|mg' $ShellStreamedit");
	}	
}

sub streamedit() {
	my $streameditItems = $CiomData->{streameditItems};
	generateStreameditFile($streameditItems);
	instanceDynamicVariablesInShellStreamedit();
	
	$CiomUtil->exec("bash $ShellStreamedit");
	$CiomUtil->exec("cat $ShellStreamedit");
}

sub runCmds($) {
	my $cmdsHierarchy = shift;
	my $cmds = Dive( $CiomData, split(' ', $cmdsHierarchy));
	if (!defined($cmds)) {
		return;
	}

	for (my $i = 0; $i <= $#{$cmds}; $i++) {
		$CiomUtil->exec($cmds->[$i]);
	}
}

sub getBuildLocation() {
	return $CiomData->{scm}->{repos}->[0]->{name};
}

sub build() {
	chdir(getBuildLocation());

	runCmds("build pre cmds");
	runCmds("build cmds");
	runCmds("build post cmds");
	
	chdir($OldPwd);
}

sub getJoinedScmModuleNames() {
	my $joinedModuleNames = '';
	my $repos = $CiomData->{scm}->{repos};
	my $cnt = $#{$repos} + 1;
	for (my $i = 0; $i < $cnt; $i++) {
		$joinedModuleNames .= $repos->[$i]->{name};
		if ($i < $cnt - 1) {
			$joinedModuleNames .= ' ';
		}
	}

	return $joinedModuleNames;
}

sub pkgApp() {
	$CiomUtil->exec("tar --exclude-vcs -czvf $AppPkgName " . getJoinedScmModuleNames());
}

sub putPkgToRepo() {
	my $appRepoLocation = "$ENV{CIOM_REPO_LOCAL_PATH}/$version/$cloudId/";
	$CiomUtil->exec("mkdir -p $appRepoLocation");
	$CiomUtil->exec("/bin/cp -f $AppPkgName $appRepoLocation");
}

sub getRemoteWorkspace() {
	return $CiomData->{dispatch}->{workspace};
}

sub dispatch() {
	my $method = Dive( $CiomData, qw( dispatch method )) || "push";
	
	my $joinedHosts = join(',', @{$CiomData->{deploy}->{hosts}}) . ',';
	my $remoteWrokspace = getRemoteWorkspace();
	my $hosts = $CiomData->{deploy}->{hosts};
	my $ansibleCmdPrefix = "ansible all -i $joinedHosts -u root";
	$CiomUtil->exec("$ansibleCmdPrefix -m file -a \"path=$remoteWrokspace state=directory\"");
	if ($method eq "push") {
		$CiomUtil->exec("$ansibleCmdPrefix -m file -a \"src=$AppPkgName dest=$remoteWrokspace\"");
	} else {
		$CiomUtil->exec("$ansibleCmdPrefix -m shell -a \"cd $remoteWrokspace; rm -rf $AppPkgName; wget $AppPkgUrl\"");
	}
}

sub getDeployAppPkgCmd($$) {
	my $idx = shift;
	my $locations = shift;

	my $remoteWrokspace = getRemoteWorkspace();
	my $mkdirCmd = "mkdir -p $locations->[$idx]";
	my $cmd = ($idx == 0) ?
				"tar -xzvf $remoteWrokspace/$AppPkgName -C $locations->[0]/"
				:
				"ln -s -f $locations->[0]/$appName $locations->[$idx]/$appName";

	return "$mkdirCmd; $cmd";
}

sub backup() {
	my $remoteWrokspace = getRemoteWorkspace();
	my $hosts = $CiomData->{deploy}->{hosts};
	for (my $i = 0; $i <= $#{$hosts}; $i++) {
		my $location = $CiomData->{deploy}->{locations}->[0];

		$CiomUtil->remoteExec({
			host => $hosts->[$i],
			cmd => "cd $location; tar -czvf $remoteWrokspace/${appName}.${Timestamp}.tar.gz ${appName}; rm -rf ${appName}"
		});	
	}
}

sub deploy() {
	runCmds("deploy pre cmds");

	my $hosts = $CiomData->{deploy}->{hosts};
	for (my $i = 0; $i <= $#{$hosts}; $i++) {
		my $locations = $CiomData->{deploy}->{locations};

		for (my $j = 0; $j <= $#{$locations}; $j++) {

			$CiomUtil->remoteExec({
				host => $hosts->[$i],
				cmd =>getDeployAppPkgCmd($j, $locations)
			});
		}
	}

	runCmds("deploy post cmds");
}

sub main() {
	loadPlugin();
	enterWorkspace();

	updateCode();
	replaceCustomiedFiles();
	fillDynamicVariables();
	streamedit();
	build();
	pkgApp();
	putPkgToRepo();
	dispatch();
	backup();
	deploy();
	leaveWorkspace();

	return 0;
}

exit main();
