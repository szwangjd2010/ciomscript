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
use File::Slurp qw(read_dir);
use YAML::XS qw(LoadFile DumpFile);
use JSON::Parse 'json_file_to_perl';
use String::Escape 'escape';
use open ":encoding(utf8)";
use open IN => ":encoding(utf8)", OUT => ":utf8";
use IO::Handle;
use CiomUtil;
use ScmActor;
STDOUT->autoflush(1);


my $version = $ARGV[0];
my $cloudId = $ARGV[1];
my $appName = $ARGV[2];

# $DeployMode: deploy or rollback
# it's corresponding to same name node which defined in %app%.ciom & %plugin%.yaml
# in deploy process, will execute pre, cmds, post actions defined in the $DeployMode node
my $DeployMode = lc($ENV{DeployMode} || 'deploy'); 
my $RollbackTo = lc($ENV{RollbackTo} || '');

my $CiomUtil = new CiomUtil(1);
my $Timestamp = $CiomUtil->getTimestamp();
my $AppVcaHome = "$ENV{CIOM_VCA_HOME}/$version/pre/$cloudId/$appName";
my $CiomData = json_file_to_perl("$AppVcaHome/ciom.json");
my $AppType = $CiomData->{AppType};
my $Output = "_output";
my $OldPwd = getcwd();

my $UDV = {}; # user-defined variable
my $AppPkg = {};
my $Consts = {};
my $Tpl;
my $Plugin;
my $RevisionId;


sub enterWorkspace() {
	chdir($ENV{WORKSPACE}) || die "can not change working directory!";
}

sub leaveWorkspace() {
	chdir($OldPwd);
}

sub initWorkspace() {
	$CiomUtil->exec("mkdir -p $Output;");
}

sub initTpl() {
	$Tpl = Template->new({
		ABSOLUTE => 1,
		TAG_STYLE => 'outline',
		PRE_CHOMP  => 0,
	    POST_CHOMP => 0
	});	
}

sub getAppPkgUrl() {
	my $repo = uc ($CiomData->{dispatch}->{repo} || "inner");
	my $repoBaseUrlKey = "CIOM_REPO_${repo}_URL";

	return sprintf("%s/%s/%s/%s/%s",
		$ENV{$repoBaseUrlKey},
		$version,
		$cloudId,
		$appName,
		$AppPkg->{name}
	);
}

sub setAppPkgInfo() {
	$AppPkg->{name} = "$appName.$RevisionId.tar.gz";
	$AppPkg->{file} = "$Output/$AppPkg->{name}";
	$AppPkg->{url} = getAppPkgUrl();
	$AppPkg->{sumfile} = "$Output/$appName.sha256sum";
	$AppPkg->{repoLocation} = "$ENV{CIOM_REPO_LOCAL}/$version/$cloudId/$appName/";

	$CiomData->{apppkg} = $AppPkg;
}

sub initConsts() {
	$Consts->{revid} = ".revid";
	$Consts->{appciomdata} = "ciom.yaml";
}

sub init() {
	initWorkspace();
	initConsts();
	initTpl();
}

sub getJobLogFile() {
	return "$ENV{JENKINS_HOME}/jobs/$ENV{JOB_NAME}/builds/$ENV{BUILD_NUMBER}/log";
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
	my $appTypeTopDomainVarsFile =  "$ENV{CIOM_SCRIPT_HOME}/plugin/vars/${appTypeTopDomain}";
	if (-e $appTypeTopDomainVarsFile) {
		$CiomData->{vars} = LoadFile($appTypeTopDomainVarsFile);
	}
}

sub getPluginFileByName {
	my ($pluginName) = @_;
	return  "$ENV{CIOM_SCRIPT_HOME}/plugin/${pluginName}.yaml";
}

sub getPluginDefinition {
	my $definitions = {};
	my $chain = [];
	local *appendPluginInheritedChainNode = sub {
		my ($name, $data) = @_;
		push(@{$chain}, $name);
		$definitions->{$name} = clone($data);
	};

	my $plugin = LoadFile(getPluginFileByName($AppType));
	appendPluginInheritedChainNode($AppType, $plugin);

	my $extend = $plugin->{__extend};
	while (defined($extend)) {
		$plugin = LoadFile(getPluginFileByName($extend));
		appendPluginInheritedChainNode($extend, $plugin);
		$extend = $plugin->{__extend};
	}

	my $ret = {};
	for (my $i = $#{$chain}; $i >= 0; $i--) {
		$ret = merge $ret, $definitions->{$chain->[$i]};
	}
	$ret = merge $ret, {__extend => $chain};
	return $ret;
}

sub dumpCiomAndPlugin() {
	$CiomData->{Timestamp} = $Timestamp;
	DumpFile("$Output/$Consts->{appciomdata}", $CiomData);
}

sub loadAndProcessPlugin() {
	my $fileAppPlugin = "$Output/${AppType}.yaml";
	my $plugin = getPluginDefinition();

	DumpFile($fileAppPlugin, $plugin);
	addTplVarsIntoCiomData();
	processTemplate($fileAppPlugin, {root => merge $CiomData, $plugin}, $fileAppPlugin);

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

sub setRevisionId {
	if ($DeployMode eq "rollback") {
		$RevisionId = $RollbackTo;
	} else {
		$RevisionId = $CiomUtil->execWithReturn("cat $CiomData->{scm}->{repos}->[0]->{name}/$Consts->{revid} | tr -d '\n'");
	}

	setAppPkgInfo();
}

sub pointoutRepoStatus {
	my $appCiomDataFile = "$Output/$Consts->{appciomdata}";
	if (! -e $appCiomDataFile) {
		return;
	}

	my $lastCiomData = LoadFile($appCiomDataFile);
	my $current = $CiomData->{scm}->{repos};
	my $last = $lastCiomData->{scm}->{repos};

	if (!defined($last)) {
		map { $_->{status} = 'new' } @{$current};
		return;
	}

	map {
		my $repo = $_;

		my @repoInLast = grep { $_->{name} eq $repo->{name} } @{$last};
		if ($#repoInLast == -1) {
			$repo->{status} = 'new';
		} else {
			if ($repo->{url} eq $repoInLast[0]->{url}) {
				$repo->{status} = 'unchanged';
			} else {
				$repo->{status} = 'changed';
			}
		}
	} @{$current};
}

sub removeUselessRepoCode() {
	my $repos = $CiomData->{scm}->{repos};
	foreach my $dir (read_dir('.')) {
    	if ($dir eq "_output") {
    		next;
    	}

    	my @repo = grep { $_->{name} eq $dir } @{$repos};
    	if ($#repo == -1
    		|| $repo[0]->{status} eq "changed") {
    		$CiomUtil->exec("rm -rf $dir");
    	}
	}
}

sub pullCode() {
	pointoutRepoStatus();
	removeUselessRepoCode();

	my $repos = $CiomData->{scm}->{repos};
	my $username = $CiomData->{scm}->{username};
	my $password = $CiomData->{scm}->{password};
	my $actor = new ScmActor($username, $password);

	foreach my $repo (@{$repos}) {
		$actor->setRepo($repo);
		my $name = $repo->{name};
		if (! -d $name) {
			$CiomUtil->exec($actor->co());
		} else {
			$CiomUtil->exec($actor->update());
		}
		$CiomUtil->exec($actor->version() . " | awk '{print \$1 \".\" \"$Timestamp\"}' > $name/$Consts->{revid}");
	}
}

sub customizeFiles() {
	my $customizedFilesLocation = "$AppVcaHome/customized/";
	if ( -d $customizedFilesLocation) {
		my $dirNotEmpty = sprintf('[ "$(ls -A %s)" ]', $customizedFilesLocation);
		$CiomUtil->exec("$dirNotEmpty && /bin/cp -rf $customizedFilesLocation/* ./");
	}
}

sub escapeRe($) {
	my $re = shift;
	#single quotation enclosed by single quotation
	$re =~ s/'/'"'"'/g;

	#vertical bar 
	$re =~ s/\|/\\|/g;

	#@
	$re =~ s/\@/\\@/g;	
	return $re;
}

sub escapeReAndGatherUDV() {
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
		}
		$pointer = $pointer->{$node};
	}

	if (defined($hostIdx) && defined($instanceIdx)) {
		my $key = "host[$hostIdx]-instance[$instanceIdx]";
		if (!defined($pointer->{$key})) {
			$pointer->{$key} = $cmds;
		}
	}
}

sub translateActions($) {
	my $cmds = shift;
	map { 
		if ($_ =~ m|^Job\(([^\)]+)\)\.run:(.+)$|) { #Job(%jobName).run
			my $jobName = $1;
			my $str = $2;
			my @kvs = split(',', $str);

			my $pms = {};
			foreach my $kv (@kvs) {
				my @tmp = split('=', $kv);
				$pms->{$tmp[0]} = $tmp[1];
			}

			$_ = $CiomUtil->getJenkinsJobCli($jobName, $pms);
		} else { # Module(%module).%tasks
			$_ =~ s|^Module\((\w+)\)\.(\w+)|fab -u $CiomData->{deployuser} -f $ENV{CIOM_SCRIPT_HOME}/module/${1}.py ${2}|;
			$_ =~ s|\\|\\\\|;
		}
	} @{$cmds};
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
		my $out = '';
		my $lasyRe = '\(% ([\w_\.\s\+\-\*\/]+) %\)';
		if ($cmd =~ m/$lasyRe/) {
			while ($cmd =~ m/$lasyRe/) {
				$cmd =~ s/$lasyRe/[% $1 %]/g;
				processTemplate(\$cmd, {root => $CiomData}, \$out);
				$cmd = $out;
			}
		} else {
			processTemplate(\$cmd, {root => $CiomData}, \$out);
			$cmd = $out;
		}
	}

	addLazyOut2CiomData(@_);
}

sub setDeployUser {
	if ( defined($CiomData->{username}) ){
		$CiomData->{deployuser} = $CiomData->{username};
	}
	else {
		$CiomData->{deployuser} = "root";
	}
}

sub remoteExec {
	my ($host, $cmds) = @_;
	my $user = $CiomData->{deployuser};
	$CiomUtil->remoteExec({
				user => $user,
				host => $host,
				cmd => $cmds
			});
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
	translateActions($clonedCmds);

	if (defined($hostIdx)) {
		my $re = "^(fab -u|java -jar /var/lib/jenkins/jenkins-cli.jar)";
		my @moduleAndJobCmds = grep { $_ =~ m"$re" } @{$clonedCmds};
		if ($#moduleAndJobCmds == -1) {
			# $CiomUtil->remoteExec({
			# 	host => $CiomData->{deploy}->{hosts}->[$hostIdx],
			# 	cmd => $clonedCmds
			# });
			remoteExec($CiomData->{deploy}->{hosts}->[$hostIdx],$clonedCmds);
			return;
		}

		foreach my $action (@{$clonedCmds}) {
			if ($action =~ m"$re") {
				$CiomUtil->exec($action);
			} else {
				# $CiomUtil->remoteExec({
				# 	host => $CiomData->{deploy}->{hosts}->[$hostIdx],
				# 	cmd => $action
				# });
				remoteExec($CiomData->{deploy}->{hosts}->[$hostIdx],$clonedCmds);
			}
		}
	} else {
		$CiomUtil->exec($clonedCmds);
	}
}

sub runCmdsInHierarchys {
	my ($hierarchys, $hostIdx, $instanceIdx) = @_;
	foreach my $hierarchy (@{$hierarchys}) {
		runHierarchyCmds($hierarchy, $hostIdx, $instanceIdx);
	}
}

sub build() {
	runCmdsInHierarchys([
		"build pre",
		"build cmds",
		"build post"
	]);
}

sub getIncludeFileRoot($) {
	my $include = shift;
	my $idxFileRoot = index($include, '^');
	if ($idxFileRoot <= 0) {
		return $include;
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
	$CiomUtil->exec("rm -rf $dir4Pkg/*");
	if ($include0 eq '*') {
		if ($reposCnt == 1) {
			$CiomUtil->exec("rsync -avh $repo0Name/* $dir4Pkg/ --delete");
		} else {
			$CiomUtil->exec("rsync -avh --exclude $Output * $dir4Pkg/ --delete");
		}
	} else {
		for (my $i = 0; $i < $includesCnt; $i++) {
			my $include = $includes->[$i];
			if ($include =~ m/^f,/) {
				$include = substr($include, 2);
				$CiomUtil->exec("/bin/cp -Rf $include $dir4Pkg/");
			} else {
				my $fileRoot = getIncludeFileRoot($include);
				$CiomUtil->exec("/bin/cp -Rf $fileRoot/* $dir4Pkg/");	
			}
		}
	}
	$CiomUtil->exec("/bin/cp -f $repo0Name/$Consts->{revid} $dir4Pkg/");
	$CiomUtil->exec("/bin/cp -f $AppPkg->{sumfile} $dir4Pkg/");	
	$CiomUtil->exec("(cd $Output; tar --exclude-vcs -czvf $ENV{WORKSPACE}/$AppPkg->{file} $appName)");		
}

sub sumPackage() {
	$CiomUtil->exec("sha256sum $AppPkg->{file} > $AppPkg->{sumfile}");
}

sub putPackageToRepo() {
	my $files = "$AppPkg->{file} $AppPkg->{sumfile}";
	$CiomUtil->exec("mkdir -p $AppPkg->{repoLocation}");
	$CiomUtil->exec("/bin/cp -f $files $AppPkg->{repoLocation}");
	if ($CiomData->{dispatch}->{repo} eq 'public') {
		my $host = $ENV{CIOM_REPO_PUBLIC_HOST};
		$CiomUtil->exec("ssh root\@$host 'mkdir -p $AppPkg->{repoLocation}'; scp $files root\@$host:$AppPkg->{repoLocation}");
	}
}

sub getRemoteWorkspace() {
	return $CiomData->{dispatch}->{workspace};
}

sub dispatch() {
	if ( $AppType =~ /win/) {
		dispatchBySsh();
	} else {
		dispatchByAnsible();
	}
}

sub dispatchByAnsible() {
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

sub dispatchBySsh() {
	my $hosts = $CiomData->{deploy}->{hosts};
	my $cnt = $#{$hosts} + 1;
	my $remoteWrokspace = getRemoteWorkspace();

	for (my $i = 0; $i < $cnt; $i++) {
		$CiomUtil->remoteExec({
					user => "ciom",
					host => $hosts->[$i],
					cmd => "md $remoteWrokspace"
				});
		$CiomUtil->exec("scp $AppPkg->{repoLocation}/$AppPkg->{name} ciom\@$hosts->[$i]:/$remoteWrokspace/");
	}
}

sub deploy() {
	runHierarchyCmds("$DeployMode local pre");

	my $locations = $CiomData->{$DeployMode}->{locations};
	my $hosts = $CiomData->{$DeployMode}->{hosts};
	my $hostsCnt = $#{$hosts} + 1;
	for (my $i = 0; $i < $hostsCnt; $i++) {
		my $host = $hosts->[$i];
		
		runHierarchyCmds("$DeployMode host pre", $i);

		for (my $j = 0; $j <= $#{$locations}; $j++) {
			runCmdsInHierarchys([
				"$DeployMode instance pre",
				"$DeployMode instance extract",
				"$DeployMode instance chownmode",
				"$DeployMode instance cmds",
				"$DeployMode instance post"
			], $i, $j);
		}

		runHierarchyCmds("$DeployMode host post", $i);

		if ($hostsCnt > 1 && $i < $hostsCnt - 1) {
			$CiomUtil->exec("sleep 3");
		}
	}

	runHierarchyCmds("$DeployMode local post");
}

sub initRollbackNode() {
	$CiomData->{rollback} = merge $CiomData->{deploy}, $CiomData->{rollback};
}

sub test() {
	runCmdsInHierarchys([
		"test function pre",
		"test function cmds",
		"test function post",
		"test performance pre",
		"test performance cmds",
		"test performance post"
	]);
}

my $Subs = [
    {fn => \&pullCode,				presence => 'deploy'},
    {fn => \&initRollbackNode,		presence => 'rollback'},
    {fn => \&setRevisionId,			presence => '.*'},
    {fn => \&loadAndProcessPlugin,	presence => '.*'},
    {fn => \&customizeFiles,		presence => 'deploy'},
    {fn => \&escapeReAndGatherUDV, 	presence => 'deploy'},
    {fn => \&streamedit,			presence => 'deploy'},
    {fn => \&build,				    presence => 'deploy'},
    {fn => \&packageApp,			presence => 'deploy'},
    {fn => \&sumPackage,			presence => 'deploy'},
    {fn => \&putPackageToRepo,		presence => 'deploy'},
    {fn => \&dispatch,				presence => '.*'},
    {fn => \&setDeployUser,			presence => '.*'},
    {fn => \&deploy,				presence => '.*'},
    {fn => \&test,					presence => '.*'},
];

sub main() {
	enterWorkspace();
	init();

	map { $DeployMode =~ m/$_->{presence}/ && $_->{fn}->() } @{$Subs};
	
	dumpCiomAndPlugin();
	leaveWorkspace();

	return 0;
}

exit main();
