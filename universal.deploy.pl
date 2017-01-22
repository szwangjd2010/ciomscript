#!/usr/bin/perl -W
# 
#
use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use English;
use Data::Dumper;
use Data::Diver qw( Dive DiveRef DiveError );
use Hash::Merge::Simple qw( merge );
use Clone 'clone';
use Template;
use Cwd;
use CiomUtil;
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

my $AppPkgName = "$appName.tar.gz";
my $AppPkgUrl = getAppPkgUrl();
my $Timestamp = $CiomUtil->getTimestamp();

my $DynamicVars = {};
my $StreameditTpl = "$ENV{CIOM_SCRIPT_HOME}/streamedit.sh.tpl";
my $ShellStreamedit = "_streamedit.ciom";
my $OldPwd = getcwd();

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
};


sub enablePlugin() {
	mergePluginAndAppSetting("build");
	mergePluginAndAppSetting("package");
	mergePluginAndAppSetting("deploy");
	mergePluginAndAppSetting("dispatch");
}

sub loadPlugin() {
	$Plugin = json_file_to_perl("$ENV{CIOM_SCRIPT_HOME}/plugins/${AppType}.ciom");
	enablePlugin();
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
		my $v = $streameditItems->{$file};
		my $cnt = $#{$v} + 1;
		
		for (my $i = 0; $i < $cnt; $i++) {
			my $vi = $v->[$i];
			$vi->{re} = escapeRe($vi->{re});
			$vi->{to} = escapeRe($vi->{to});

			if ($vi->{to} =~ m|<ciompm>([\w_]+)</ciompm>|) {
				$DynamicVars->{$1} = $ENV{"CIOMPM_$1"} || '';
				#ciom dynamic variable to template directive
				$vi->{to} =~ s|<ciompm>([\w_]+)</ciompm>|[% DynamicVars.$1 %]|g;
			}
		}
	}
}

sub generateStreameditFile() {
	transformReAndGatherDynamicVars();

	my $template = Template->new({
		ABSOLUTE => 1,
		TAG_STYLE => 'outline',
		PRE_CHOMP  => 0,
	    POST_CHOMP => 0,
	});

	my $firstOut =  "${ShellStreamedit}.0";
	# instance stream edit items
	$template->process($StreameditTpl, {files => $CiomData->{streameditItems}}, $firstOut)
        || die "Template process failed - 0: ", $template->error(), "\n";
    $CiomUtil->exec("cat $firstOut");

    # instance dynamic variables
	$template->process($firstOut, {DynamicVars => $DynamicVars}, $ShellStreamedit)
        || die "Template process failed - 1: ", $template->error(), "\n";
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
	chdir(firstModuleName());

	runHierarchyCmds("build pre");
	runHierarchyCmds("build cmds");
	runHierarchyCmds("build post");
	
	chdir($OldPwd);
}

sub getJoinedModules() {
	my $repos = $CiomData->{scm}->{repos};
	my $modules = '';
	my $cnt =  $#{$repos} + 1;
	for (my $i = 0; $i < $cnt; $i++) {
		$modules .= $repos->[$i]->{name};
		if ($i != $cnt - 1) {
			$modules .= ' ';
		}
	}
	return $modules;
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
	my $customizedPkgIncludes = Dive($O_CiomData, qw(package includes));
	my $prefix = defined($customizedPkgIncludes) ? '' : firstModuleName();
	my $includes = $CiomData->{package}->{includes};

	if ($includes->[0] eq '*') {
		my $joinedModules = getJoinedModules();
		$CiomUtil->exec("tar --exclude-vcs -czvf $AppPkgName $joinedModules");	
	} else {
		my $tmpWorkspace = "$ENV{WORKSPACE}/_tmp";
		my $dir4CollectPkgFiles = "$tmpWorkspace/$appName";

		@{$includes} = map "$prefix/$_", @{$includes};
		$CiomUtil->exec("mkdir -p $dir4CollectPkgFiles; rm -rf $dir4CollectPkgFiles/*");
		for (my $i = 0; $i <= $#{$includes}; $i++) {
			my $fileRoot = getIncludeFileRoot($includes->[$i]);
			$CiomUtil->exec("(cd $fileRoot; /bin/cp -Rf * $dir4CollectPkgFiles/)");
		}
		$CiomUtil->exec("(cd $tmpWorkspace; tar --exclude-vcs -czvf $ENV{WORKSPACE}/$AppPkgName $appName)");		
	}

	$CiomUtil->exec("sha256sum $AppPkgName > $appName.sha256sum");
}

sub putPkgToRepo() {
	my $appRepoLocation = "$ENV{CIOM_REPO_LOCAL_PATH}/$version/$cloudId/";
	$CiomUtil->exec("mkdir -p $appRepoLocation");
	$CiomUtil->exec("/bin/cp -f $AppPkgName $appName.sha256sum $appRepoLocation");
}

sub getRemoteWorkspace() {
	return $CiomData->{dispatch}->{workspace};
}

sub dispatch() {
	my $method = Dive( $CiomData, qw( dispatch method )) || "push";
	
	my $joinedHosts = join(',', @{$CiomData->{deploy}->{hosts}}) . ',';
	my $remoteWrokspace = getRemoteWorkspace();
	my $ansibleCmdPrefix = "ansible all -i $joinedHosts -u root";
	$CiomUtil->exec("$ansibleCmdPrefix -m file -a \"path=$remoteWrokspace state=directory\"");
	if ($method eq "push") {
		$CiomUtil->exec("$ansibleCmdPrefix -m file -a \"src=$AppPkgName dest=$remoteWrokspace\"");
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
	runHierarchyCmds("deploy local pre");

	my $owner = Dive($CiomData, qw(deploy owner)) || '';
	my $hosts = $CiomData->{deploy}->{hosts};
	for (my $i = 0; $i <= $#{$hosts}; $i++) {
		my $host = $hosts->[$i];
		my $locations = $CiomData->{deploy}->{locations};

		runHierarchyCmds("deploy pre", $host);

		for (my $j = 0; $j <= $#{$locations}; $j++) {
			$CiomUtil->remoteExec({
				host => $host,
				cmd => getDeployAppPkgCmd($j, $locations)
			});
		}
		if ($owner ne '') {
			$CiomUtil->remoteExec({
				host => $host,
				cmd => "chown -R $owner:$owner " . join(' ', @{$locations})
			});
		}
		
		runHierarchyCmds("deploy post", $host);
	}

	runHierarchyCmds("deploy local post");
}

sub main() {
	enterWorkspace();
	loadPlugin();
	updateCode();
	replaceCustomiedFiles();
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
