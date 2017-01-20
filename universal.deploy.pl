#!/usr/bin/perl -W
# 
#
use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use English;
use Data::Dumper;
use Data::Diver qw( Dive DiveRef DiveError );
use Hash::Merge qw( merge );
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

my $DynamicVars = {};
my $StreameditTpl = "$ENV{CIOM_SCRIPT_HOME}/streamedit.sh.tpl";
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

sub enablePlugin($) {
	my $plugin = shift;
	Hash::Merge::set_behavior('RETAINMENT_PRECEDENT');
	$CiomData->{build} = merge $plugin->{build}, $CiomData->{build} || {};
	$CiomData->{deploy} = merge $plugin->{deploy}, $CiomData->{deploy};
	$CiomData->{dispatch} = merge $plugin->{dispatch}, $CiomData->{dispatch} || {};
}


sub loadPlugin() {
	my $plugin = json_file_to_perl("$ENV{CIOM_SCRIPT_HOME}/plugins/${AppType}.ciom");
	enablePlugin($plugin);
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

sub escapeRe($) {
	my $re = shift;
	#single quotation enclosed by single quotation
	$re =~ s/'/'"'"'/g;

	#vertical bar 
	$re =~ s/\|/\\|/g;	
	return $re;
}

sub transformStreameditsReAndFillDynamicVars() {
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
				$vi->{to} =~ s|<ciompm>([\w_]+)</ciompm>|[% DynamicVars.$1 %]|g;
			}
		}
	}
}

sub generateStreameditFile() {
	transformStreameditsReAndFillDynamicVars();

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

sub runCmdsInHierarchy($) {
	my $cmdsHierarchy = shift;
	my $cmds = Dive($CiomData, split(' ', $cmdsHierarchy));
	if (defined($cmds)) {
		$CiomUtil->exec($cmds);
	}
}

sub getBuildLocation() {
	return $CiomData->{scm}->{repos}->[0]->{name};
}

sub build() {
	chdir(getBuildLocation());

	runCmdsInHierarchy("build pre cmds");
	runCmdsInHierarchy("build cmds");
	runCmdsInHierarchy("build post cmds");
	
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
	my $hosts = $CiomData->{deploy}->{hosts};
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
	runCmdsInHierarchy("deploy pre cmds");

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

	runCmdsInHierarchy("deploy post cmds");
}

sub main() {
	loadPlugin();
	enterWorkspace();

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
