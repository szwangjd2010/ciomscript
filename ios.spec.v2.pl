our $version;
our $cloudId;
our $appName;

our $ciomUtil;
our $AppVcaHome;
our $ApppkgPath;
our $CiomData;
our $distDetail;
our $executorIdx;

my $BuildInfo = $CiomData->{build};
my $Slave4MobileDeploy = json_file_to_perl("$ENV{CIOM_SCRIPT_HOME}/slaves4mobiledeploy.json");
my $appWorkspaceOnSlave;
my $outAppDirectory;
my $cmdUnlockKeychain;
my $cmdGotoAppWsOnSlave;

my $SshInfo = {
	port => '22',
	user => 'ciom'
};

sub globalPreAction() {}
sub globalPostAction() {}
sub preAction() {}
sub postAction() {}

sub getCiomEnv($) {
	my $slaveIdx=shift;
	my $id = $Slave4MobileDeploy->{ios}->[$slaveIdx]->{ciSlaveId} ;
	my $ciomENV = "";
	if ($id == 0) {
		$ciomENV = "CIOM_SLAVE_OSX_WORKSPACE";
	} else {
		$ciomENV = sprintf("CIOM_SLAVE_OSX%s_WORKSPACE",$id);
	}
	return $ciomENV;
} 

sub getCiomHost() {
	my $slaveIdx = $distDetail->{slaveid} ;
	return $Slave4MobileDeploy->{ios}->[$slaveIdx]->{ip};
} 

sub getCiSlaveId($) {
	my $slaveIdx=shift;
	return $Slave4MobileDeploy->{ios}->[$slaveIdx]->{ciSlaveId};
}

sub getAppWorkspaceOnSlave(){
	my $workspaceId = $distDetail->{wsid};
	my $appWsOnSlave = "/Users/ciom/ciomws/ws${workspaceId}/$version/$cloudId/$appName";
	return $appWsOnSlave;
}

sub resyncSourceCode() {
	my $slaveidx = $distDetail->{slaveid};
	my $workspaceIdx = $distDetail->{wsid};
	my $ciSlaveId = getCiSlaveId($slaveidx);
	logBuildingStatus(0,"=== Start sync SourceCode to osx salve: slave${slaveidx}, ws${workspaceIdx} ===");
	$ciomUtil->exec("$ENV{CIOM_SCRIPT_HOME}/syncup.to.osx.slave.sh $slaveidx $workspaceIdx $version $cloudId $appName $ciSlaveId");
	logBuildingStatus(0,"=== end sync SourceCode to osx salve ===");
}

sub generateBuildCmd() {
	my $cmd;
	if ($BuildInfo->{type} eq 'target') {
		$cmd = sprintf("xcodebuild -target %s -configuration %s -sdk %s %s",
			$BuildInfo->{typeTargetName},
			$BuildInfo->{configuration},
			$BuildInfo->{sdk},
			$BuildInfo->{target}
		);
	} else {
		$cmd = sprintf("xcodebuild -workspace %s.xcworkspace -scheme %s -configuration %s -sdk %s %s",
			$BuildInfo->{typeTargetName},
			$BuildInfo->{typeTargetName},
			$BuildInfo->{configuration},
			$BuildInfo->{sdk},
			$BuildInfo->{target}
		);		
	}

	return $cmd;
}

sub getAppBuiltOutLocation($) {
	my $appWsOnSlave = shift;
	if ($BuildInfo->{type} eq 'target') {
		return "$appWsOnSlave/$BuildInfo->{location}/build/Release-iphoneos/$BuildInfo->{typeTargetName}.app";
	} else {
		return "$appWsOnSlave/$BuildInfo->{location}/build/Products/Release-iphoneos/$BuildInfo->{typeTargetName}.app";
	}	
}

sub initCmds() {
	$appWorkspaceOnSlave = getAppWorkspaceOnSlave();
	$outAppDirectory = getAppBuiltOutLocation($appWorkspaceOnSlave);	
	$cmdUnlockKeychain = "security -v unlock-keychain -p pwdasdwx /Users/ciom/Library/Keychains/login.keychain";
	$cmdGotoAppWsOnSlave = "cd $appWorkspaceOnSlave";
	$SshInfo->{host} = getCiomHost();
} 

sub buildWithoutPackage() {
	preAction();
	resyncSourceCode();

	my $build = $CiomData->{build};
	#following all directory are remote directory
	my $cmd2Workspace = "cd $appWorkspaceOnSlave/$BuildInfo->{location}";
	#fix issue - "User Interaction Is Not Allowed"
	my $cmdUnlockKeychain = "security -v unlock-keychain -p pwdasdwx /Users/ciom/Library/Keychains/login.keychain";
	#end
	my $cmdBuild = generateBuildCmd();
	
	$SshInfo->{cmd} = "( $cmd2Workspace; $cmdUnlockKeychain; $cmdBuild)";
	logBuildingStatus(0,"=== Start remote execute build ===");
	logBuildingStatus(0,"cmd is $SshInfo->{cmd}");
	$ciomUtil->remoteExec($SshInfo);
	logBuildingStatus(0,"=== end remote execute build ===");
	postAction();
}

sub syncAppFolder() {
	$SshInfo->{cmd} = "rsync -az --delete --force $outAppDirectory/ $appWorkspaceOnSlave/$BuildInfo->{typeTargetName}.app/";
	$ciomUtil->remoteExec($SshInfo);
}

sub replaceOrgCustomizedFilesToSlave($) {
	my $code = $_[0];
	my $ciomhost = getCiomHost();
	my $orgCustomizedHome = "$AppVcaHome/resource/$code";
	$ciomUtil->exec("scp -P $SshInfo->{port} -r $orgCustomizedHome/* $SshInfo->{user}\@$ciomhost:$appWorkspaceOnSlave/$BuildInfo->{typeTargetName}.app/");
}

sub removeCodeSign() {
	$SshInfo->{cmd} = "rm -rf $appWorkspaceOnSlave/$BuildInfo->{typeTargetName}.app/_CodeSignature";
	$ciomUtil->remoteExec($SshInfo);
}

sub remoteStreamedit($) {
	my $items = $_[0];
	generateStreameditFile($items);
	instantiateDynamicParamsInStreameditFile();
	$ciomUtil->exec("scp -P $SshInfo->{port} -r $ShellStreamedit $SshInfo->{user}\@$SshInfo->{host}:$appWorkspaceOnSlave/");
	my $cmdConvertPlistFiles = "plutil -convert xml1 $BuildInfo->{typeTargetName}.app/*.plist";
	$SshInfo->{cmd} = "( $cmdGotoAppWsOnSlave; $cmdConvertPlistFiles; bash $ShellStreamedit)";
	$ciomUtil->remoteExec($SshInfo);
	$ciomUtil->exec("cat $ShellStreamedit");
	$ciomUtil->exec("cat $ShellStreamedit >> _streamedit.ciom.all");
}

sub remoteStreameditConfs4Org($) {
	my $code = $_[0];
	my $streameditItems = $CiomData->{orgs}->{$code}->{streameditItems};
	$ciomUtil->exec("echo '$code' >> _streamedit.ciom.all");
	logBuildingStatus(0,"=== start streameditConfs4Org ===");
	remoteStreamedit($streameditItems);
	logBuildingStatus(0,"=== end streameditConfs4Org ===");
}
sub replaceEntitlementsPlist() {
	$ciomUtil->exec("scp -P $SshInfo->{port} -r $AppVcaHome/Entitlements.plist $SshInfo->{user}\@$SshInfo->{host}:$appWorkspaceOnSlave/");
}

sub reCodeSign($) {
	my $code = $_[0];
	my $certname = $CiomData->{orgs}->{$code}->{certname};
	my $cmdCodeSign = "/usr/bin/codesign -f -s \"$certname\" --entitlements $appWorkspaceOnSlave/Entitlements.plist $appWorkspaceOnSlave/$BuildInfo->{typeTargetName}.app";
	$SshInfo->{cmd} = "( $cmdUnlockKeychain; $cmdCodeSign )";
	$ciomUtil->remoteExec($SshInfo);
}

sub packageIpa() {
	my $ipaFile = "$appWorkspaceOnSlave/$BuildInfo->{location}/$BuildInfo->{typeTargetName}.ipa";
	my $cmdPackage = "xcrun -sdk iphoneos PackageApplication -v $appWorkspaceOnSlave/$BuildInfo->{typeTargetName}.app -o $ipaFile";
	$SshInfo->{cmd} = "$cmdPackage";
	$ciomUtil->remoteExec($SshInfo);
}


sub updateResourceAndPackage($) {
	my $code = $_[0];
	syncAppFolder();
	replaceEntitlementsPlist();
	replaceOrgCustomizedFilesToSlave($code);
	removeCodeSign();
	remoteStreameditConfs4Org($code);
	reCodeSign($code);
	packageIpa();
}

sub moveApppkgFile($) {
	my $code = $_[0];
	my $slaveId = $distDetail->{slaveid} ;
	my $wsId = $distDetail->{wsid};
			
	#sleep for fixing following issue
	#/bin/cp -rf WebSchool/eschool.ipa /var/lib/jenkins/jobs/mobile.ios-eschool/builds/37/app/eschool_ios_barcotest.ipa 
	#/bin/cp: skipping file `WebSchool/eschool.ipa', as it was replaced while being copied
	#$ciomUtil->exec("sleep 2");
	my $appFinalPkgName = getAppFinalPkgName($code);
	my $slaveENV = getCiomEnv($slaveId);
	my $orgIpaFile = "$ENV{$slaveENV}/ws${wsId}/$version/$cloudId/$appName/$BuildInfo->{location}/$BuildInfo->{typeTargetName}.ipa";
	$ciomUtil->exec("mv $orgIpaFile $ApppkgPath/$appFinalPkgName");
}

sub cleanAfterOrgBuild() {
	;
}



