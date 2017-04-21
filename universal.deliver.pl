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

# $DeliverMode: deploy or rollback
# it's corresponding to same name node which defined in %app%.ciom & %plugin%.yaml
# in deploy process, will execute pre, cmds, post actions defined in the $DeliverMode node
my $DeliverMode = $ARGV[3] || 'deploy'; 
my $RollbackTo = $ARGV[4] || '';

my $CiomUtil = new CiomUtil(1);
my $Timestamp = $CiomUtil->getTimestamp();
my $AppVcaHome = "$ENV{CIOM_VCA_HOME}/$version/pre/$cloudId/$appName";
my $CiomData = json_file_to_perl("$AppVcaHome/ciom.json");
my $AppType = $CiomData->{AppType};
my $Output = "_output";
my $OldPwd = getcwd();

my $DynamicVars = {};
my $AppPkg = {};
my $Rollback = {};
my $Plugin;
my $Tpl;
my $RevisionId;


sub getBuildLogFile() {
	return "$ENV{JENKINS_HOME}/jobs/$ENV{JOB_NAME}/builds/$ENV{BUILD_NUMBER}/log";
}

sub getAppPkgUrl() {
	my $repoId = uc ($CiomData->{dispatch}->{repoId} || "inner");
	my $repoBaseUrlKey = "CIOM_REPO_BASE_URL_$repoId";

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

sub streamedit() {
	my $StreameditTpl = "$ENV{CIOM_SCRIPT_HOME}/streamedit.sh.tpl";
	my $StreameditFile = "$Output/streamedit.ciom";
	my $firstOut =  "${StreameditFile}.0";

	processTemplate($StreameditTpl, {files => $CiomData->{streameditItems}}, $firstOut);
    $CiomUtil->exec("cat $firstOut");
    
    processTemplate($firstOut, {DynamicVars => $DynamicVars}, $StreameditFile);
    $CiomUtil->exec("cat $StreameditFile");
	$CiomUtil->exec("bash $StreameditFile");
}

sub runHierarchyCmds {
	my ($hierarchyCmds, $host) = @_;
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
	my $mkdirCmd = "mkdir -p $locations->[$idx]";
	my $cmd = ($idx == 0) ?
				"tar -xzvf $remoteWrokspace/$AppPkg->{name} -C $locations->[0]/"
				:
				"rm -rf $locations->[$idx]/$appName; ln -s $locations->[0]/$appName $locations->[$idx]/$appName";

	return "$mkdirCmd; $cmd";
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
	runHierarchyCmds("$DeliverMode local pre");

	my $permissions = getPermissions();
	my $locations = $CiomData->{$DeliverMode}->{locations};
	my $hosts = $CiomData->{$DeliverMode}->{hosts};
	my $hostsCnt = $#{$hosts} + 1;
	for (my $i = 0; $i < $hostsCnt; $i++) {
		my $host = $hosts->[$i];
		
		runHierarchyCmds("$DeliverMode host pre", $host);

		for (my $j = 0; $j <= $#{$locations}; $j++) {
			runHierarchyCmds("$DeliverMode instance pre", $host);
			$CiomUtil->remoteExec({
				host => $host,
				cmd => getUnpackCmdByLocationIdx($j, $locations)
			});
			runHierarchyCmds("$DeliverMode instance cmds", $host);
			runHierarchyCmds("$DeliverMode instance post", $host);
		}

		setPermissions($host, $locations, $permissions);
		runHierarchyCmds("$DeliverMode host post", $host);

		if ($hostsCnt > 1 && $i < $hostsCnt - 1) {
			$CiomUtil->exec("sleep 5");
		}
	}

	runHierarchyCmds("$DeliverMode local post");
}

sub delivermode_deploy() {
	updateCode();
	setRevisionId();
	initAppPkgInfo();

	customizeFiles();
	transformReAndGatherDynamicVars();
	streamedit();
	
	build();

	packageApp();
	sumPackage();
	putPackageToRepo();
	
	dispatch();
	deploy();
}

# begin - delivermode_rollback subs
sub initRollbackNode() {
	$CiomData->{rollback} = merge $CiomData->{deploy}, $CiomData->{rollback};
}

sub delivermode_rollback() {
	initRollbackNode();

	setRevisionId($RollbackTo);
	initAppPkgInfo();
	
	dispatch();
	deploy();
}
# end - delivermode_rollback subs 

sub main() {
	enterWorkspace();
	initWorkspace();
	initTpl();
	loadPlugin();
	
	eval("delivermode_${DeliverMode}()");

	persistCiomAndPluginInfo();
	leaveWorkspace();
	return 0;
}

exit main();
