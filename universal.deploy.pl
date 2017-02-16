#!/usr/bin/perl -W
# 
#
use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use warnings;
use English;
use Data::Dumper;
use Data::Diver qw(Dive DiveRef DiveError);
use Hash::Merge::Simple qw(merge);
use Clone 'clone';
use Template;
use Cwd;
use CiomUtil;
use YAML::XS qw(LoadFile DumpFile);
use JSON::Parse 'json_file_to_perl';
use String::Escape 'escape';
use open ":encoding(utf8)";
use open IN => ":encoding(utf8)", OUT => ":utf8";
use IO::Handle;
STDOUT->autoflush(1);

sub getAppPkgUrl();

my $version = $ARGV[0];
my $cloudId = $ARGV[1];
my $appName = $ARGV[2];

my $CiomUtil = new CiomUtil(1);
my $AppVcaHome = "$ENV{CIOM_VCA_HOME}/$version/pre/$cloudId/$appName";
my $CiomData = json_file_to_perl("$AppVcaHome/ciom.json");
my $O_CiomData = clone($CiomData);
my $AppType = $CiomData->{AppType};
my $Plugin;

my $Output = "_output";
my $AppPkgName = "$appName.tar.gz";
my $AppPkgFile = "$Output/$AppPkgName";
my $AppPkgUrl = getAppPkgUrl();
my $AppPkgSumFile = "$Output/$appName.sha256sum";
my $Timestamp = $CiomUtil->getTimestamp();

my $DynamicVars = {};
my $StreameditTpl = "$ENV{CIOM_SCRIPT_HOME}/streamedit.sh.tpl";
my $ShellStreamedit = "$Output/streamedit.ciom";
my $OldPwd = getcwd();
my $Tpl = Template->new({
		ABSOLUTE => 1,
		TAG_STYLE => 'outline',
		PRE_CHOMP  => 0,
	    POST_CHOMP => 0
	});

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

sub mergePluginAndAppSetting($) {
	my $section = shift;
	$CiomData->{$section} = merge $Plugin->{$section}, $CiomData->{$section} || {};
}

sub dumpCiomDataWithPluginInfo() {
	DumpFile("$Output/ciom.yaml", $CiomData);
}

sub loadPlugin() {
	my $filePlugin = "$ENV{CIOM_SCRIPT_HOME}/plugins/${AppType}.yaml";
	my $fileAppPlugin = "$Output/${AppType}.yaml";

	$CiomUtil->exec("/bin/cp -f $filePlugin $fileAppPlugin");
	$CiomUtil->exec("perl -i -pE 's/%([\\w_]+)%/[% PluginVars.\\1 %]/g' $fileAppPlugin");
	
	$Tpl->process($fileAppPlugin, {
			PluginVars => {
				AppRoot => $CiomData->{scm}->{repos}->[0]->{name},
				DeployLocation => $CiomData->{deploy}->{locations}->[0],
				AppName => $appName
			}
		}, $fileAppPlugin)
        || die "Template process failed - 1: ", $Tpl->error(), "\n";

	$Plugin = LoadFile($fileAppPlugin);

	my $NeedToMergeSections = [
		"build",
		"package",
		"deploy",
		"dispatch"
	];
	foreach my $section (@{$NeedToMergeSections}) {
		mergePluginAndAppSetting($section);
	}

	dumpCiomDataWithPluginInfo();
}

sub enterWorkspace() {
	chdir($ENV{WORKSPACE});
}

sub initWorkspace() {
	$CiomUtil->exec("mkdir -p $Output");
}

sub leaveWorkspace() {
	chdir($OldPwd);
}

sub updateCode() {
	my $repos = $CiomData->{scm}->{repos};
	my $username = $CiomData->{scm}->{username};
	my $password = $CiomData->{scm}->{password};

	my $cmdSvnPrefix = "svn --non-interactive --username $username --password '$password'";
	my $cmdRmUnversionedTpl = "$cmdSvnPrefix status %s | grep '^?' | awk '{print \$2}' | xargs -I{} rm -rf '{}'";
	
	foreach my $repo (@{$repos}) {
		my $name = $repo->{name};
		my $url = $repo->{url};

		if (! -d $name) {
			$CiomUtil->exec("$cmdSvnPrefix co $url $name");
		} else {
			my $removeUnversionedCmd = sprintf($cmdRmUnversionedTpl, $name);
			$CiomUtil->exec([
				$removeUnversionedCmd,
				"$cmdSvnPrefix revert -R $name",
				"$cmdSvnPrefix update $name"
			]);
		}					
	}
}

sub replaceCustomiedFiles() {
	my $customizedFilesLocation = "$AppVcaHome/customized/";
	if ( -d $customizedFilesLocation) {
		$CiomUtil->exec("/bin/cp -rf $customizedFilesLocation/* ./");
	}
}

sub escapeRe($) {
	my $re = shift;
	#single quotation enclosed by single quotation
	$re =~ s/'/'"'"'/g;

	#vertical bar 
	$re =~ s/\|/\\|/g;	
	return $re;
}

sub transformReAndGatherDynamicVars() {
	my $streameditItems = $CiomData->{streameditItems};
	for my $file (keys %{$streameditItems}) {
		foreach my $substitute (@{$streameditItems->{$file}}) {
			$substitute->{re} = escapeRe($substitute->{re});
			$substitute->{to} = escapeRe($substitute->{to});
			
			if ($substitute->{to} =~ m|<ciompm>([\w_]+)</ciompm>|) {
				$DynamicVars->{$1} = $ENV{"CIOMPM_$1"} || '';
				#ciom dynamic variable to template directive
				$substitute->{to} =~ s|<ciompm>([\w_]+)</ciompm>|[% DynamicVars.$1 %]|g;
			}
		}		
	}
}

sub generateStreameditFile() {
	transformReAndGatherDynamicVars();

	my $firstOut =  "${ShellStreamedit}.0";
	# instance stream edit items
	$Tpl->process($StreameditTpl, {files => $CiomData->{streameditItems}}, $firstOut)
        || die "Template process failed - 0: ", $Tpl->error(), "\n";
    $CiomUtil->exec("cat $firstOut");

    # instance dynamic variables
	$Tpl->process($firstOut, {DynamicVars => $DynamicVars}, $ShellStreamedit)
        || die "Template process failed - 1: ", $Tpl->error(), "\n";

    $CiomUtil->exec("cat $ShellStreamedit");
}

sub streamedit() {
	generateStreameditFile();
	$CiomUtil->exec("bash $ShellStreamedit");
}

sub runHierarchyCmds {
	my ( $hierarchyCmds, $host ) = @_;
	my $cmds = Dive($CiomData, split(' ', $hierarchyCmds));
	if (!defined($cmds)) {
		return;
	}

	if (defined($host)) {
		$CiomUtil->remoteExec({
			host => $host,
			cmd => $cmds
		});
	} else {
		$CiomUtil->exec($cmds);
	}
}

sub firstModuleName() {
	return $CiomData->{scm}->{repos}->[0]->{name};
}

sub build() {
	my $CmdsInHierarchys = [
		"build pre",
		"build cmds",
		"build post"
	];
	foreach my $hierarchy (@{$CmdsInHierarchys}) {
		runHierarchyCmds($hierarchy);
	}
}

sub getIncludeFileRoot($) {
	my $include = shift;
	my $idxFileRoot = index($include, '^');
	if ($idxFileRoot <= 0) {
		return '.';
	}
	return substr($include, 0, $idxFileRoot);	
}

sub pkgApp() {
	my $includes = $CiomData->{package}->{includes};
	my $repos = $CiomData->{scm}->{repos};
	my $includesCnt = $#{$includes} + 1;
	my $reposCnt = $#{$repos} + 1;
	my $repo0Name = $repos->[0]->{name};
	my $include0 = $includes->[0];

	if ($include0 eq '*' 
		&& $reposCnt == 1 
		&& $repo0Name eq $appName) {
		$CiomUtil->exec("tar --exclude-vcs -czvf $AppPkgFile * --exclude $Output");
		
		return;
	}

	my $dir4Pkg = "$Output/$appName";
	$CiomUtil->exec("mkdir -p $dir4Pkg");
	if ($include0 eq '*') {
		if ($reposCnt == 1) {
			$CiomUtil->exec("rsync -avh $repo0Name/* $dir4Pkg/ --delete");
		} else {
			$CiomUtil->exec("rsync -avh --exclude $Output * $dir4Pkg/ --delete");
		}
	} else {
		for (my $i = 0; $i < $includesCnt; $i++) {
			my $fileRoot = getIncludeFileRoot($includes->[$i]);
			$CiomUtil->exec("/bin/cp -Rf $fileRoot/* $dir4Pkg/");
		}
	}
	$CiomUtil->exec("(cd $Output; tar --exclude-vcs -czvf $ENV{WORKSPACE}/$AppPkgFile $appName)");		
}

sub sumPkg() {
	$CiomUtil->exec("sha256sum $AppPkgFile > $AppPkgSumFile");
}

sub putPkgToRepo() {
	my $appRepoLocation = "$ENV{CIOM_REPO_LOCAL_PATH}/$version/$cloudId/";
	$CiomUtil->exec("mkdir -p $appRepoLocation");
	$CiomUtil->exec("/bin/cp -f $AppPkgFile $AppPkgSumFile $appRepoLocation");
}

sub getRemoteWorkspace() {
	return $CiomData->{dispatch}->{workspace};
}

sub dispatch() {
	my $method = Dive( $CiomData, qw(dispatch method)) || "push";
	
	my $joinedHosts = join(',', @{$CiomData->{deploy}->{hosts}}) . ',';
	my $remoteWrokspace = getRemoteWorkspace();
	my $ansibleCmdPrefix = "ansible all -i $joinedHosts -u root";
	$CiomUtil->exec("$ansibleCmdPrefix -m file -a \"path=$remoteWrokspace state=directory\"");
	if ($method eq "push") {
		$CiomUtil->exec("$ansibleCmdPrefix -m file -a \"src=$AppPkgFile dest=$remoteWrokspace\"");
	} else {
		$CiomUtil->exec("$ansibleCmdPrefix -m get_url -a \"url=$AppPkgUrl dest=$remoteWrokspace\"");
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
				"rm -rf $locations->[$idx]/$appName; ln -s $locations->[0]/$appName $locations->[$idx]/$appName";

	return "$mkdirCmd; $cmd";
}

sub backup() {
	my $remoteWrokspace = getRemoteWorkspace();
	my $baseFindCmd = "find $remoteWrokspace -name '${appName}.*.tar.gz' -mtime +15";
	my $location = $CiomData->{deploy}->{locations}->[0];
	my $hosts = $CiomData->{deploy}->{hosts};

	foreach my $host (@{$hosts}) {
		$CiomUtil->remoteExec({
			host => $host,
			cmd => [
				"cd $location; tar -czvf $remoteWrokspace/${appName}.${Timestamp}.tar.gz ${appName}; rm -rf ${appName}",
				"((( \$($baseFindCmd | wc -l) > 5 ))) && $baseFindCmd -delete"
			]
		});
	}
}

sub setOwnerAndMode($) {
	my $info = shift;
	my $host = $info->{host};
	my $owner = $info->{owner};
	my $mode = $info->{mode};
	my $locations = $info->{locations};

	my $joinedLocations = join(' ', @{$locations});
	if ($owner ne '') {
		$CiomUtil->remoteExec({
			host => $host,
			cmd => "chown -R $owner:$owner $joinedLocations"
		});
	}
	if ($mode ne '') {
		$CiomUtil->remoteExec({
			host => $host,
			cmd => "chmod -R $mode $joinedLocations"
		});
	}
}

sub deploy() {
	runHierarchyCmds("deploy local pre");

	my $owner = Dive($CiomData, qw(deploy owner)) || '';
	my $mode = Dive($CiomData, qw(deploy mode)) || '';
	my $locations = $CiomData->{deploy}->{locations};
	my $hosts = $CiomData->{deploy}->{hosts};
	foreach my $host (@{$hosts}) {
		runHierarchyCmds("deploy pre", $host);

		for (my $j = 0; $j <= $#{$locations}; $j++) {
			$CiomUtil->remoteExec({
				host => $host,
				cmd => getDeployAppPkgCmd($j, $locations)
			});
		}

		setOwnerAndMode({
			host => $host,
			owner => $owner,
			mode => $mode,
			locations => $locations
		});
		
		runHierarchyCmds("deploy post", $host);
	}

	runHierarchyCmds("deploy local post");
}

sub main() {
	enterWorkspace();
	initWorkspace();
	loadPlugin();
	updateCode();
	replaceCustomiedFiles();
	streamedit();
	build();
	pkgApp();
	sumPkg();
	putPkgToRepo();
	dispatch();
	backup();
	deploy();
	leaveWorkspace();

	return 0;
}

exit main();
