#!/usr/bin/perl -W
# 
#
use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use English;
use Data::Dumper;
use Hash::Merge::Simple qw( merge );
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
	return sprintf("$ENV{CIOM_DISPATCH_BASE_URL}%s/%s/%s.tar.gz",
		$version,
		$cloudId,
		$appName
	);
}

sub loadAppTypePlugin() {
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
	my $appWorkspace = "$ENV{WORKSPACE}/$appName";
	if (! -d $appWorkspace) {
		$CiomUtil->exec("mkdir -p $appWorkspace");
	}

	chdir($appWorkspace);
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

sub replaceCustomiedFiles($) {
	my $code = $_[0];
	$CiomUtil->exec("/bin/cp -rf $AppVcaHome/* ./");
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
	my $cmds = Dive( $CiomData, $cmdsHierarchy);
	if (!defined($cmds)) {
		return;
	}

	for (my $i; $i <= $#{$cmds}; $i++) {
		$CiomUtil->exec($cmds->[$i]);
	}
}

sub build() {
	runCmds(qw( build pre cmds ));
	runCmds(qw( build cmds ));
	runCmds(qw( build post cmds ));
}

sub dispatch() {
	my $method = Dive( $CiomData, qw( dispatch method )) || "push";
	
	my $joinedHosts = join(',', @{$CiomData->{deploy}->{hosts}}) . ',';
	my $hosts = $CiomData->{deploy}->{hosts};
	if ($method eq "push") {
		$CiomUtil->exec("ansible all -i $joinedHosts -m file -a \"src=$AppPkgName dst=/tmp/\"");
	} else {
		$CiomUtil->exec("ansible all -i $joinedHosts -a \"cd /tmp; wget $AppPkgUrl\"");
	}
}

sub getPlaceAppPkgCmd($) {
	my $info = shift;

	my $idx = info->{idx};
	my $extract = info->{extract};
	my $locations = info->{locations};
	if (idx == 0) {
		return $extract == 1 ? 
			"tar -xzvf /tmp/$AppPkgName -C $locations->[0]/"
			:
			"/bin/cp -f /tmp/$AppPkgName $locations->[$idx]/";
	} else {
		return $extract == 1 ?
			"ln -s -f $locations->[0]/$appName $locations->[$idx]/$appName"
			:
			"ln -s -f $locations->[0]/$AppPkgName  $locations->[$idx]/$AppPkgName";
	}
}

sub backup($) {
	my $info = shift;

	$CiomUtil->remoteExec({
		host => $hosts->[$i],
		cmd => "cd $tar -czvf ${appName}.${Timestamp}.tar.gz ${appName"
	});	
}

sub deploy() {
	runCmds(qw( deploy pre cmds ));

	my $extract = Dive($CiomData, qw( deploy extract )) || 1;
	my $hosts = $CiomData->{deploy}->{hosts};
	for (my $i = 0; $i <= $#{$hosts}; $i++) {
		my $locations = $CiomData->{deploy}->{locations};

		for (my $j = 0; $j <= $#{$locations}; $j++) {
			my $info = {
				idx => $j,
				extract => $extract,
				locations => $locations
			};
			my $cmd = getPlaceAppPkgCmd($info);

			$CiomUtil->remoteExec({
				host => $hosts->[$i],
				cmds => [
					"tar -czvf $appName ${appName}.${Timestamp}.tar.gz ${appName}",
					$cmd
				]
			});
		}
	}

	runCmds(qw( deploy post cmds ));
}

sub main() {
	loadAppTypePlugin();
	
	enterWorkspace();
	updateCode();
	replaceCustomiedFiles();
	fillDynamicVariables();
	streamedit();
	preBuild();
	build();
	postBuild();
	deploy();
	leaveWorkspace();

	return getBuildError();
}

exit main();
