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

my $version = $ARGV[0];
my $cloudId = $ARGV[1];
my $appName = $ARGV[2];
my $orgCodes = $ARGV[3] || '*';

my $ciomUtil = new CiomUtil(0);
my $OldPwd = getcwd();

my $Ciom_VCA_Home = "$ENV{JENKINS_HOME}/workspace/ver.env.specific/$version/pre/$cloudId/$appName";
my $CiomData = json_file_to_perl("$Ciom_VCA_Home/ciom.json");

#print Dumper($CiomData);
sub enterWorkspace();
sub leaveWorkspace();
sub getCustomizedResourcePath($$);
sub handleOrgs();
sub pullCodes();
sub replaceOrgCustomizedFiles($);
sub streameditOrgConfs($);
sub streamedit4All();
sub _streamedit($);
sub renameAPKFile($);
sub build();
sub clean();
sub main();


sub enterWorkspace() {
	;
}

sub leaveWorkspace() {
	chdir($OldPwd);
}

sub getCustomizedResourcePath($$) {
	my $code = $_[0];
	my $fileName = $_[1];
	return "$Ciom_VCA_Home/resource/$code/$fileName";
}

sub handleOrgs() {
	my $orgs = $CiomData->{orgs};
	for my $code (keys %{$orgs}) {
		my $re = '(^|,)' . $code . '($|,)';
		if ($orgCodes eq '*' || $orgCodes =~ m/$re/) {
			replaceOrgCustomizedFiles($code);
			streameditOrgConfs($code);
			build();
			renameAPKFile($code);
			clean();
		}
	}	
}

sub build() {
	$ciomUtil->exec("ant -f Eschool/build.xml release");
}

sub renameAPKFile($) {
	my $code = $_[0];
	$ciomUtil->exec("mv /tmp/ciom.android/Elearning-release.apk $Ciom_VCA_Home/apk/eschool_android_$code.apk");
}

sub clean() {
	$ciomUtil->exec("rm -rf /tmp/ciom.android/*");
}

sub pullCodes() {
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
			$ciomUtil->exec("$cmdSvnPrefix revert $name");
			$ciomUtil->exec("$cmdSvnPrefix update $name");
		}
	}
}

sub replaceOrgCustomizedFiles($) {
	my $code = $_[0];
	my $customizedItems = $CiomData->{orgs}->{$code}->{customizedItems};

	for my $name (keys %{$customizedItems}) {
		my $srcFile = getCustomizedResourcePath($code, $name);
		my $dstFile = $customizedItems->{$name};
		$ciomUtil->exec("/bin/cp -rf $srcFile $dstFile");
	}	
}

sub _streamedit($) {
	my $items = $_[0];

	my $cmds = "";
	my $CmdStreameditTpl = "perl -i -pE 's|%s|%s|mg' %s";
	for my $file (keys %{$items}) {
		my $v = $items->{$file};
		my $cnt = $#{$v} + 1;
		
		for (my $i = 0; $i < $cnt; $i++) {
			$cmds .= sprintf($CmdStreameditTpl, 
				$v->[$i]->{re},
				$v->[$i]->{to},
				$file
			);
			$cmds .= "\n";
		}
	}

	my $fileSE = "_streamedit.ciom";	
	$ciomUtil->write("$fileSE", $cmds);
	$ciomUtil->exec("bash $fileSE");
	$ciomUtil->exec("cat $fileSE", 1);
}

sub streameditOrgConfs($) {
	my $code = $_[0];
	my $streameditItems = $CiomData->{orgs}->{$code}->{streameditItems};
	_streamedit($streameditItems);
}

sub streamedit4All() {
	my $streameditItems = $CiomData->{streameditItems};
	_streamedit($streameditItems);
}


sub main() {
	enterWorkspace();
	pullCodes();
	streamedit4All();
	handleOrgs();
	leaveWorkspace();
}

main();
