#!/usr/bin/perl -W
# 
#
package UniveralDeliver;

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
use File::Slurp;
use YAML::XS qw(LoadFile DumpFile);
use JSON::Parse 'json_file_to_perl';
use String::Escape 'escape';
use open ":encoding(utf8)";
use open IN => ":encoding(utf8)", OUT => ":utf8";
use IO::Handle;
use CiomUtil;
STDOUT->autoflush(1);

my $version = $ARGV[0];
my $cloudId = $ARGV[1];
my $appName = $ARGV[2];

# $DeployMode: deploy or rollback
# it's corresponding to same name node which defined in %app%.ciom & %plugin%.yaml
# in deploy process, will execute pre, cmds, post actions defined in the $DeployMode node
my $DeployMode = lc($ENV{DeployMode}) || 'deploy'; 
my $RollbackTo = lc($ENV{RollbackTo}) || '';

my $CiomUtil = new CiomUtil(1);
my $Timestamp = $CiomUtil->getTimestamp();
my $AppVcaHome = "$ENV{CIOM_VCA_HOME}/$version/pre/$cloudId/$appName";
my $CiomData = json_file_to_perl("$AppVcaHome/ciom.json");
my $AppType = $CiomData->{AppType};
my $Output = "_output";
my $OldPwd = getcwd();

my $UDV = {}; # user-defined variable
my $AppPkg = {};
my $Rollback = {};
my $Plugin;
my $Tpl;
my $RevisionId;


sub getBuildLogFile() {
	return "$ENV{JENKINS_HOME}/jobs/$ENV{JOB_NAME}/builds/$ENV{BUILD_NUMBER}/log";
}

sub getAppPkgUrl() {
	my $repo = uc ($CiomData->{dispatch}->{repo} || "inner");
	my $repoBaseUrlKey = "CIOM_REPO_BASE_URL_$repo";

	return sprintf("%s/%s/%s/%s/%s",
		$ENV{$repoBaseUrlKey},
		$version,
		$cloudId,
		$appName,
		$AppPkg->{name}
	);
}

sub initTpl() {
	$Tpl = Template->new({
		ABSOLUTE => 1,
		TAG_STYLE => 'outline',
		PRE_CHOMP  => 0,
	    POST_CHOMP => 0
	});	
}

sub initAppPkgInfo() {
	$AppPkg->{name} = "$appName.$RevisionId.tar.gz";
	$AppPkg->{file} = "$Output/$AppPkg->{name}";
	$AppPkg->{url} = getAppPkgUrl();
	$AppPkg->{sumfile} = "$Output/$appName.sha256sum";
	$AppPkg->{repoLocation} = "$ENV{CIOM_REPO_LOCAL_PATH}/$version/$cloudId/$appName/";
}

sub processTemplate {
	my ($in, $data, $out) = @_;
	$Tpl->process($in, $data, $out) 
		|| die "Template process failed: ", $Tpl->error(), "\n";	
}

sub addTplVarsIntoCiomData {
	$CiomData->{vca} = {
		version => $version,
		cloudId => $cloudId,
		appName => $appName		
	};

	my $appTypeTopDomain = substr($AppType, 0, index($AppType, '.'));
	my $appTypeTopDomainVarsFile =  "$ENV{CIOM_SCRIPT_HOME}/plugins/vars/${appTypeTopDomain}";
	if (-e $appTypeTopDomainVarsFile) {
		$CiomData->{vars} = LoadFile($appTypeTopDomainVarsFile);
	}
}

sub getPluginDefinition {
	my $plugins = {};
	my $chain = [];
	local *appendPluginInheritedChainNode = sub {
		my ($name, $data) = @_;
		push(@{$chain}, $name);
		$plugins->{$name} = clone($data);
	};

	local *getPluginFileByName = sub {
		my ($pluginName) = @_;
		return  "$ENV{CIOM_SCRIPT_HOME}/plugins/${pluginName}.yaml";
	};

	my $plugin = LoadFile(getPluginFileByName($AppType));
	appendPluginInheritedChainNode($AppType, $plugin);

	my $extend = $plugin->{__extend};
	while (defined($extend)) {
		$plugin = LoadFile(getPluginFileByName($extend));
		appendPluginInheritedChainNode($extend, $plugin);
		$extend = $plugin->{__extend};
	}

	my $definition = {};
	for (my $i = $#{$chain}; $i >= 0; $i--) {
		$definition = merge $definition, $plugins->{$chain->[$i]};
	}
	$definition = merge $definition, {__extend => $chain};
	return $definition;
}

sub persistCiomAndPluginInfo() {
	$CiomData->{Timestamp} = $Timestamp;
	$CiomData->{AppPkg} = $AppPkg;
	$CiomData->{Rollback} = $Rollback;
	DumpFile("$Output/ciom.yaml", $CiomData);
}

sub loadPlugin() {
	my $fileAppPlugin = "$Output/${AppType}.yaml";
	my $plugin = getPluginDefinition();
	DumpFile($fileAppPlugin, $plugin);
	
	addTplVarsIntoCiomData();
	processTemplate($fileAppPlugin, {root => $CiomData}, $fileAppPlugin);
	$Plugin = LoadFile($fileAppPlugin);

	my $SectionsToMerge = [
		"build",
		"package",
		"deploy",
		"dispatch"
	];
	foreach my $section (@{$SectionsToMerge}) {
		$CiomData->{$section} = merge $Plugin->{$section}, $CiomData->{$section} || {};
	}
}

sub enterWorkspace() {
	chdir($ENV{WORKSPACE}) || die "can not change working directory!";
}

sub initWorkspace() {
	$CiomUtil->exec("mkdir -p $Output");
}

sub leaveWorkspace() {
	chdir($OldPwd);
}

sub setRevisionId {
	my ($id) = @_;
	if (defined($id)) {
		$RevisionId = $id;	
	} else {
		$RevisionId = $CiomUtil->execWithReturn("cat $CiomData->{scm}->{repos}->[0]->{name}/.revid | tr -d '\n'");
	}

	print $RevisionId;
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
		$CiomUtil->exec("$cmdSvnPrefix info $name > $name/.repoinfo");
		$CiomUtil->exec("grep -P '(Revision|Last Changed Rev)' $name/.repoinfo | awk -F': ' '{print \$2}' | tr '\n', '.' | awk '{print \$1 \"$Timestamp\"}' > $name/.revid");
	}
}

sub customizeFiles() {
	my $customizedFilesLocation = "$AppVcaHome/customized/";
	if ( -d $customizedFilesLocation) {
		my $dirNotEmpty = sprintf('[ "$(ls -A %s)" ]', $customizedFilesLocation);
		$CiomUtil->exec("$dirNotEmpty && /bin/cp -rf $customizedFilesLocation ./");
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

sub transformReAndGatherUDV() {
	my $streameditItems = $CiomData->{streameditItems};
	for my $file (keys %{$streameditItems}) {
		foreach my $substitute (@{$streameditItems->{$file}}) {
			$substitute->{re} = escapeRe($substitute->{re});
			$substitute->{to} = escapeRe($substitute->{to});
			
			if ($substitute->{to} =~ m|<ciompm>([\w_]+)</ciompm>|) {
				$UDV->{$1} = $ENV{"CIOMPM_$1"} || '';
				#ciom dynamic variable to template directive
				$substitute->{to} =~ s|<ciompm>([\w_]+)</ciompm>|[% UDV.$1 %]|g;
			}
		}		
	}
}

sub streamedit() {
	my $StreameditTpl = "$ENV{CIOM_SCRIPT_HOME}/streamedit.sh.tpl";
	my $StreameditFile = "$Output/streamedit.ciom";
	my $firstOut =  "${StreameditFile}.0";

	processTemplate($StreameditTpl, {files => $CiomData->{streameditItems}}, $firstOut);
    $CiomUtil->exec("cat $firstOut");
    
    processTemplate($firstOut, {UDV => $UDV}, $StreameditFile);
    $CiomUtil->exec("cat $StreameditFile");
	$CiomUtil->exec("bash $StreameditFile");
}

sub addLazyOut2CiomData {
	my ($hierarchyArr, $cmds, $hostIdx, $instanceIdx) = @_;
	my $lazyOutKey = "lazyout";
	if (!defined($CiomData->{$lazyOutKey})) {
		$CiomData->{$lazyOutKey} = {};
	}

	my $pointer = $CiomData->{$lazyOutKey};
	foreach my $node (@{$hierarchyArr}) {
		if (!defined($pointer->{$node})) {
			$pointer->{$node} = {};
			$pointer = $pointer->{$node};
		}
	}

	my $key = "host[$hostIdx]-instance[$instanceIdx]";
	if (!defined($pointer->{$key})) {
		$pointer->{$key} = $cmds;
	}
}

sub lazyProcessCmds {
	my ($hierarchyArr, $cmds, $hostIdx, $instanceIdx) = @_;
	my $vars = {
		hostIdx => $hostIdx,
		instanceIdx => $instanceIdx
	};

	my $needProcess = 0;
	foreach my $val (values %{$vars}) {
		if (defined($val)) {
			$needProcess = 1;
			last;
		}
	}
	if (!$needProcess) {
		return;
	}

	foreach my $cmd (@{$cmds}) {
		$cmd =~ s/%([\w\d]+)%/$vars->{$1}/g;
		$cmd =~ s/%% ([\w\d\.]+) %%/[% $1 %]/g;

		my $out = '';
		processTemplate(\$cmd, {root => $CiomData}, \$out);
		$cmd = $out;
	}

	addLazyOut2CiomData(@_);
}

sub runHierarchyCmds {
	my ($hierarchyCmds, $hostIdx, $instanceIdx) = @_;
	my @hierarchyArr = split(' ', $hierarchyCmds);
	my $cmds = Dive($CiomData, @hierarchyArr);
	if (!defined($cmds) || $#{$cmds} == -1) {
		return;
	}

	my $clonedCmds = clone($cmds); 
	lazyProcessCmds(\@hierarchyArr, $clonedCmds, $hostIdx, $instanceIdx);

	if (defined($hostIdx)) {
		$CiomUtil->remoteExec({
			host => $CiomData->{deploy}->{hosts}->[$hostIdx],
			cmd => $clonedCmds
		});
	} else {
		$CiomUtil->exec($clonedCmds);
	}
}

sub runCmdsInHierarchys {
	my ($hierarchys) = @_;
	foreach my $hierarchy (@{$hierarchys}) {
		runHierarchyCmds($hierarchy);
	}
}

sub build() {
	my $CmdsInHierarchys = [
		"build pre",
		"build cmds",
		"build post"
	];
	runCmdsInHierarchys($CmdsInHierarchys);
}

sub getIncludeFileRoot($) {
	my $include = shift;
	my $idxFileRoot = index($include, '^');
	if ($idxFileRoot <= 0) {
		return '.';
	}
	return substr($include, 0, $idxFileRoot);	
}

sub packageApp() {
	my $includes = $CiomData->{package}->{includes};
	my $repos = $CiomData->{scm}->{repos};
	my $includesCnt = $#{$includes} + 1;
	my $reposCnt = $#{$repos} + 1;
	my $repo0Name = $repos->[0]->{name};
	my $include0 = $includes->[0];

	if ($include0 eq '*' 
		&& $reposCnt == 1 
		&& $repo0Name eq $appName) {
		$CiomUtil->exec("tar --exclude-vcs -czvf $AppPkg->{file} * --exclude $Output");
		
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
	$CiomUtil->exec("/bin/cp -f *.revinfo *.rev $Output/");	
	$CiomUtil->exec("(cd $Output; tar --exclude-vcs -czvf $ENV{WORKSPACE}/$AppPkg->{file} $appName)");		
}

sub sumPackage() {
	$CiomUtil->exec("sha256sum $AppPkg->{file} > $AppPkg->{sumfile}");
}

sub putPackageToRepo() {
	$CiomUtil->exec("mkdir -p $AppPkg->{repoLocation}");
	$CiomUtil->exec("/bin/cp -f $AppPkg->{file} $AppPkg->{sumfile} $AppPkg->{repoLocation}");
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
		$CiomUtil->exec("$ansibleCmdPrefix -m copy -a \"src=$AppPkg->{repoLocation}/$AppPkg->{name} dest=$remoteWrokspace\"");
	} else {
		$CiomUtil->exec("$ansibleCmdPrefix -m get_url -a \"url=$AppPkg->{url} dest=$remoteWrokspace\"");
	}
}

sub getUnpackCmdByLocationIdx($$) {
	my $idx = shift;
	my $locations = shift;

	my $remoteWrokspace = getRemoteWorkspace();
	my $idxLocation = $locations->[$idx];
	my $idxAppLocation = "$idxLocation/$appName";

	my $cmd = "tar -xzvf $remoteWrokspace/$AppPkg->{name} -C $idxLocation/";
	if (!$CiomData->{deploy}->{multiphysical} == 0 && $idx != 0) {
		$cmd = "ln -s $locations->[0]/$appName $idxLocation/$appName";
	}

	return sprintf("%s; %s; %s",
		"mkdir -p $idxLocation",
		"[ -d $idxAppLocation ] && rm -rf $idxAppLocation",
		$cmd
	);
}

sub setPermissions {
	my ($host, $locations, $permissions) = @_;
	my $joinedLocations = join(' ', @{$locations});
	if ($permissions->{owner} ne '') {
		$CiomUtil->remoteExec({
			host => $host,
			cmd => "chown -R $permissions->{owner}:$permissions->{group} $joinedLocations"
		});
	}
	if ($permissions->{mode} ne '') {
		$CiomUtil->remoteExec({
			host => $host,
			cmd => "chmod -R $permissions->{mode} $joinedLocations"
		});
	}
}

sub getPermissions() {
	return {
		owner => Dive($CiomData, qw(deploy owner)) || '',
		group => Dive($CiomData, qw(deploy group)) || '',
		mode => Dive($CiomData, qw(deploy mode)) || ''
	};
}

sub deploy() {
	runHierarchyCmds("$DeployMode local pre");

	my $permissions = getPermissions();
	my $locations = $CiomData->{$DeployMode}->{locations};
	my $hosts = $CiomData->{$DeployMode}->{hosts};
	my $hostsCnt = $#{$hosts} + 1;
	for (my $i = 0; $i < $hostsCnt; $i++) {
		my $host = $hosts->[$i];
		
		runHierarchyCmds("$DeployMode host pre", $i);

		for (my $j = 0; $j <= $#{$locations}; $j++) {
			runHierarchyCmds("$DeployMode instance pre", $i, $j);
			$CiomUtil->remoteExec({
				host => $host,
				cmd => getUnpackCmdByLocationIdx($j, $locations)
			});
			runHierarchyCmds("$DeployMode instance cmds", $i, $j);
			runHierarchyCmds("$DeployMode instance post", $i, $j);
		}

		setPermissions($host, $locations, $permissions);
		runHierarchyCmds("$DeployMode host post", $i);

		if ($hostsCnt > 1 && $i < $hostsCnt - 1) {
			$CiomUtil->exec("sleep 5");
		}
	}

	runHierarchyCmds("$DeployMode local post");
}

sub deploymode_deploy() {
	updateCode();
	setRevisionId();
	initAppPkgInfo();

	customizeFiles();
	transformReAndGatherUDV();
	streamedit();
	
	build();

	packageApp();
	sumPackage();
	putPackageToRepo();
	
	dispatch();
	deploy();
}

# begin - deploymode_rollback subs
sub initRollbackNode() {
	$CiomData->{rollback} = merge $CiomData->{deploy}, $CiomData->{rollback};
}

sub deploymode_rollback() {
	initRollbackNode();

	setRevisionId($RollbackTo);
	initAppPkgInfo();
	
	dispatch();
	deploy();
}
# end - deploymode_rollback subs 

sub test() {
	my $CmdsInHierarchys = [
		"test function pre",
		"test function cmds",
		"test function post",
		"test performance pre",
		"test performance cmds",
		"test performance post"
	];
	runCmdsInHierarchys($CmdsInHierarchys);
}


sub main() {
	enterWorkspace();
	initWorkspace();
	initTpl();
	loadPlugin();
	
	eval("deploymode_${DeployMode}()");

	persistCiomAndPluginInfo();
	test();
	leaveWorkspace();
	return 0;
}

exit main();
