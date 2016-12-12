our $version;
our $cloudId;
our $appName;

our $ciomUtil;
our $AppVcaHome;
our $ApppkgPath;
our $CiomData;
our $distDetail;
our $executorIdx;

my $AppWorkspaceOnSlave = "/Users/ciom/ciomws/$version/$cloudId/$appName";
my $BuildInfo = $CiomData->{build};
my $Slave4MobileDeploy = json_file_to_perl("$ENV{CIOM_SCRIPT_HOME}/slaves4mobiledeploy.json");
my $AppCertData = json_file_to_perl("$ENV{CIOM_APPCERT_HOME}/$appName/cert.json");

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
	$ciomUtil->exec("$ENV{CIOM_SCRIPT_HOME}/syncup.to.osx.slave.sh $executorIdx $workspaceIdx $version $cloudId $appName $ciSlaveId");
	logBuildingStatus(0,"=== end sync SourceCode to osx salve ===");
}

sub generateReplaceIdentifierCmd($) {
	my $code = $_[0];
	my $cmd =""; 
	my $identifier = $appCertData->{$code}->{appidentifier};
	if ( $appName eq 'daxue' ) {
		#$cmd = "sed -i '' 's/cn.yunxuetang.daxue/$identifier/g' $appName.xcodeproj/project.pbxproj";
		$cmd = "perl -0 -i -pE \"s|(?<g1>PRODUCT_BUNDLE_IDENTIFIER = )(?<g2>[^<>]+)(?<g3>;)|\$\+{g1}$identifier\$\+{g3}|sg\" $appName.xcodeproj/project.pbxproj";
	}
	return $cmd;
}

sub generateBuildCmd($) {
	my $code = $_[0];
	my $cmd;
	my $csIdentify = $AppCertData->{$code}->{certname}; 
	my $uuid = $AppCertData->{$code}->{uuid};
	if ($BuildInfo->{type} eq 'target') {
		$cmd = sprintf("xcodebuild -target %s -configuration %s -sdk %s %s",
			$BuildInfo->{typeTargetName},
			$BuildInfo->{configuration},
			$BuildInfo->{sdk},
			$BuildInfo->{target}
		);
	} else {
		$cmd = sprintf("xcodebuild -workspace %s.xcworkspace -scheme %s -configuration %s -sdk %s %s CODE_SIGN_IDENTITY=\"%s\" PROVISIONING_PROFILE=\"%s\" ENABLE_BITCODE=NO",
			$BuildInfo->{typeTargetName},
			$BuildInfo->{typeTargetName},
			$BuildInfo->{configuration},
			$BuildInfo->{sdk},
			$BuildInfo->{target},
			$csIdentify,
			$uuid
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

sub build($) {
	my $code = $_[0];
	preAction();
	resyncSourceCode();
	my $appWorkspaceOnSlave = getAppWorkspaceOnSlave();
	my $build = $CiomData->{build};
	
	#following all directory are remote directory
	my $cmd2Workspace = "cd $appWorkspaceOnSlave/$BuildInfo->{location}";
	#fix issue - "User Interaction Is Not Allowed"
	my $cmdUnlockKeychain = "security -v unlock-keychain -p pwdasdwx /Users/ciom/Library/Keychains/login.keychain";
	#end
	my $cmdBuild = generateBuildCmd($code);
	my $outAppDirectory = getAppBuiltOutLocation($appWorkspaceOnSlave);
	my $ipaFile = "$appWorkspaceOnSlave/$BuildInfo->{location}/$BuildInfo->{typeTargetName}.ipa";
	my $cmdPackage = "xcrun -sdk iphoneos PackageApplication -v $outAppDirectory -o $ipaFile";
	

	$SshInfo->{cmd} = "( $cmd2Workspace; $cmdUnlockKeychain; $cmdBuild; $cmdPackage )";
	$SshInfo->{host} = getCiomHost();

	logBuildingStatus(0,"=== Start remote execute build ===");
	logBuildingStatus(0,"cmd is $SshInfo->{cmd}");
	
	$ciomUtil->remoteExec($SshInfo);
	logBuildingStatus(0,"=== end remote execute build ===");
	postAction();
}

sub moveApppkgFile($) {
	my $code = $_[0];
	my $slaveId = $distDetail->{slaveid} ;
	my $wsId = $distDetail->{wsid};
			
	#sleep for fixing following issue
	#/bin/cp -rf WebSchool/eschool.ipa /var/lib/jenkins/jobs/mobile.ios-eschool/builds/37/app/eschool_ios_barcotest.ipa 
	#/bin/cp: skipping file `WebSchool/eschool.ipa', as it was replaced while being copied
	$ciomUtil->exec("sleep 5");
	my $appFinalPkgName = getAppFinalPkgName($code);
	my $appWorkspaceOnSlave = getAppWorkspaceOnSlave();
	my $slaveENV = getCiomEnv($slaveId);
	my $orgIpaFile = "$ENV{$slaveENV}/ws${wsId}/$version/$cloudId/$appName/$BuildInfo->{location}/$BuildInfo->{typeTargetName}.ipa";
	$ciomUtil->exec("mv $orgIpaFile $ApppkgPath/$appFinalPkgName");
}

sub cleanAfterOrgBuild() {
	;
}



