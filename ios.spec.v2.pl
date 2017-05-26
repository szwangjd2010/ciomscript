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
my $reCodeSignIpa = "$BuildInfo->{typeTargetName}-reCodeSign.ipa";
my $Slave4MobileDeploy = json_file_to_perl("$ENV{CIOM_SCRIPT_HOME}/slaves4mobiledeploy.json");
my $AppCertData = json_file_to_perl("$ENV{CIOM_APPCERT_HOME}/$appName/cert.json");
my $remoteAppCertWs = "/Users/ciom/ciomws/wsappcert/$appName";
my $jobLogFile = "$ENV{JENKINS_HOME}/jobs/$ENV{JOB_NAME}/builds/$ENV{BUILD_NUMBER}/log";
my $appWorkspaceOnSlave;
my $cmdUnlockKeychain;
my $cmdGotoAppWsOnSlave;
my $cmd2Workspace;
my $enterpriseWs;
my $appstoreWs;
my $enterpriseExportPlist = "enterprise.plist";
my $appSotoreExportPlist = "app-store.plist";
my $OrgInfo = {};
my $enterpriseOrgCount = 0;
my $appstoreOrgCount = 0;

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

sub generateArchiveCmd() {
	my $cmd;
	$cmd = sprintf("xcodebuild clean archive -workspace %s.xcworkspace -scheme %s -configuration %s -archivePath %s.xcarchive",
		$BuildInfo->{typeTargetName},
		$BuildInfo->{typeTargetName},
		$BuildInfo->{configuration},
		$BuildInfo->{typeTargetName}
	);		

	return $cmd;
}

sub generateExportIpaCmd($) {
	my $type = shift;
	my $ipaName = "";
	if ($type eq 'Enterprise') {
		$exportPath = $enterpriseWs;
		$optionPlistPath = "$appWorkspaceOnSlave/$enterpriseExportPlist";
	}
	else {
		$exportPath = $appstoreWs;
		$optionPlistPath = "$appWorkspaceOnSlave/$appSotoreExportPlist";
	}
	my $cmd;
	$cmd = sprintf("xcodebuild -exportArchive -archivePath %s.xcarchive -configuration %s -exportPath %s -exportOptionsPlist %s",
		$BuildInfo->{typeTargetName},
		$BuildInfo->{configuration},
		$exportPath,
		$optionPlistPath
	);		

	return $cmd;
}

sub preActionForArchiveAppStorePackage() {
	my $code = $BuildInfo->{appStoreArchiveBaseOrg};
	$DynamicParams->{DEVELOPMENT_TEAM} = $AppCertData->{$code}->{UID};
	$DynamicParams->{CODE_SIGN_IDENTITY} = $AppCertData->{$code}->{CN};
	$DynamicParams->{PROVISIONING_PROFILE} = $AppCertData->{$code}->{uuid};
	$DynamicParams->{PROVISIONING_PROFILE_SPECIFIER} = $AppCertData->{$code}->{ProfileSpecifier};
	logBuildingStatus(0,"=== start streamedit for appstore archive ===");
	my $items1 = $CiomData->{appstoreStreameditItems};
	remoteStreamedit($items1);
	logBuildingStatus(0,"=== end streamedit for appsotre archive ===");
}

sub initial() {
	$appWorkspaceOnSlave = getAppWorkspaceOnSlave();
	$enterpriseWs = "$appWorkspaceOnSlave/enterprise-ws";
	$appstoreWs = "$appWorkspaceOnSlave/appstore-ws";
	$cmdUnlockKeychain = "security -v unlock-keychain -p pwdasdwx /Users/ciom/Library/Keychains/login.keychain";
	$cmdGotoAppWsOnSlave = "cd $appWorkspaceOnSlave";
	$cmd2Workspace = "cd $appWorkspaceOnSlave/$BuildInfo->{location}";
	$SshInfo->{host} = getCiomHost();
} 

sub archivePackage() {
	preAction();
	my $build = $CiomData->{build};
	my $cmdBuild = generateArchiveCmd();
	$SshInfo->{cmd} = "( $cmd2Workspace; $cmdUnlockKeychain; $cmdBuild)";
	logBuildingStatus(0,"=== Start remote execute build ===");
	logBuildingStatus(0,"cmd is $SshInfo->{cmd}");
	$ciomUtil->remoteExec($SshInfo);
	logBuildingStatus(0,"=== end remote execute build ===");
	postAction();
}

sub syncAppFolder() {
	$SshInfo->{cmd} = "";
	$ciomUtil->remoteExec($SshInfo);
}

sub replaceOrgCustomizedFilesToSlave() {
	my $code = $OrgInfo->{code};
	my $ciomhost = getCiomHost();
	my $orgCustomizedHome = "$AppVcaHome/resource/$code";
	$ciomUtil->exec("scp -P $SshInfo->{port} -r $orgCustomizedHome/* $SshInfo->{user}\@$ciomhost:$OrgInfo->{extractedAppFolder}/");
}

sub replaceExportOptionPlistToSlave() {
	my $ciomhost = getCiomHost();
	#my $orgCustomizedHome = "$AppVcaHome/resource/$code";
	$ciomUtil->exec("scp -P $SshInfo->{port} -r $AppVcaHome/*.plist $SshInfo->{user}\@$ciomhost:$appWorkspaceOnSlave/");
}

sub removeCodeSign() {
	$SshInfo->{cmd} = "rm -rf $OrgInfo->{workspace}/Payload/$BuildInfo->{typeTargetName}.app/_CodeSignature";
	$ciomUtil->remoteExec($SshInfo);
}

sub extractIpaByOrg() {
	$SshInfo->{cmd} = "cd $OrgInfo->{workspace}; unzip -o -q $BuildInfo->{typeTargetName}.ipa";
	$ciomUtil->remoteExec($SshInfo);
}

sub backupAppStoreArchive() {
	my $backupTargetPath = "/Users/ciom/ciomws/archive.backup/$version/$cloudId/$appName/AppStore";
	my $zipArchiveCmd = "zip -q -r $backupTargetPath/$ENV{CIOMPM_CFBundleShortVersionString}_$ENV{BUILD_NUMBER}.zip $BuildInfo->{typeTargetName}.xcarchive";
	$SshInfo->{cmd} = "( mkdir -p $backupTargetPath; $cmd2Workspace; $zipArchiveCmd )";
	$ciomUtil->remoteExec($SshInfo);
}

sub backupEnterpriseArchive() {
	my $backupTargetPath = "/Users/ciom/ciomws/archive.backup/$version/$cloudId/$appName/Enterprise";
	my $zipArchiveCmd = "zip -q -r $backupTargetPath/$ENV{CIOMPM_CFBundleShortVersionString}_$ENV{BUILD_NUMBER}.zip $BuildInfo->{typeTargetName}.xcarchive";
	$SshInfo->{cmd} = "( mkdir -p $backupTargetPath; $cmd2Workspace; $zipArchiveCmd )";
	$ciomUtil->remoteExec($SshInfo);
}

sub extractIpa() {
	my $cmdExtractForEnterprise = "cd $enterpriseWs; unzip -o -q $BuildInfo->{typeTargetName}.ipa";
	my $cmdExtractForAppstore = "cd $appstoreWs; unzip -o -q $BuildInfo->{typeTargetName}.ipa";
	#my $cmdExtractForAppstore = "";
	$SshInfo->{cmd} = "( $cmdExtractForEnterprise; $cmdExtractForAppstore)";
	$ciomUtil->remoteExec($SshInfo);
}

sub remoteStreamedit($) {
	my $items = $_[0];
	generateStreameditFile($items);
	instantiateDynamicParamsInStreameditFile();
	$ciomUtil->exec("scp -P $SshInfo->{port} -r $ShellStreamedit $SshInfo->{user}\@$SshInfo->{host}:$appWorkspaceOnSlave/");
	$SshInfo->{cmd} = "( $cmdGotoAppWsOnSlave; bash $ShellStreamedit)";
	$ciomUtil->remoteExec($SshInfo);
	$ciomUtil->exec("cat $ShellStreamedit");
	$ciomUtil->exec("cat $ShellStreamedit >> _streamedit.ciom.all");
}

sub convertPlist() {
	my $cmdConvertPlistFiles = "plutil -convert xml1 $OrgInfo->{extractedAppFolder}/*.plist";
	$SshInfo->{cmd} = $cmdConvertPlistFiles;
	$ciomUtil->remoteExec($SshInfo);
}

sub remoteStreameditConfs4Org() {
	my $code = $OrgInfo->{code};
	my $streameditItems = $CiomData->{orgs}->{$code}->{streameditItems};
	$ciomUtil->exec("echo '$code' >> _streamedit.ciom.all");
	logBuildingStatus(0,"=== start streameditConfs4Org ===");
	convertPlist();
	remoteStreamedit($streameditItems);
	logBuildingStatus(0,"=== end streameditConfs4Org ===");
}

sub updateEntitlementsPlist(){
	my $code = $OrgInfo->{code};
	my $appId = $AppCertData->{$code}->{appId};
	$cmdUpdateApplicaitonIdentifier = "ssh $SshInfo->{user}\@$SshInfo->{host} \"perl -CSDL -0 -i -pE \'s|(<key>application-identifier</key>\\s+<string>)[^<>]+(</string>)|\\\${1}$appId\\\${2}|mg\' $appWorkspaceOnSlave/Entitlements.plist\"";
	$ciomUtil->exec($cmdUpdateApplicaitonIdentifier);
	$cmdUpdateApplicaitonIdentifier = "ssh $SshInfo->{user}\@$SshInfo->{host} \"perl -CSDL -0 -i -pE \'s|(<key>keychain-access-groups</key>\\s+<array>\\s+<string>)[^<>]+(</string>)|\\\${1}$appId\\\${2}|mg\' $appWorkspaceOnSlave/Entitlements.plist\"";
	$ciomUtil->exec($cmdUpdateApplicaitonIdentifier);
}

sub replaceEntitlementsPlist() {
	my $cpEntPListCmd = "cp -r $appWorkspaceOnSlave/Entitlements.plist $OrgInfo->{extractedAppFolder}/archived-expanded-entitlements.xcent";
	$SshInfo->{cmd} = $cpEntPListCmd;
	$ciomUtil->remoteExec($SshInfo);
}

sub replaceMobileProvision() {
	my $code = $OrgInfo->{code};
	my $rplcPrvCmd = "cp -r $remoteAppCertWs/$code/$code.mobileprovision $OrgInfo->{extractedAppFolder}/embedded.mobileprovision";
	$SshInfo->{cmd} = $rplcPrvCmd;
	$ciomUtil->remoteExec($SshInfo);
}

sub reCodeSign() {
	my $certname = $OrgInfo->{certInfo}->{CN};
	my $cmdCodeSign = "/usr/bin/codesign -f -s \"$certname\" --entitlements $appWorkspaceOnSlave/Entitlements.plist $OrgInfo->{extractedAppFolder}";
	$SshInfo->{cmd} = "( $cmdUnlockKeychain; $cmdCodeSign )";
	$ciomUtil->remoteExec($SshInfo);
}
sub verifyCodeSign() {
	my $cmdVerify1 = "/usr/bin/codesign -vv -d $OrgInfo->{extractedAppFolder}";
	my $cmdVerify2 = "/usr/bin/codesign --verify $OrgInfo->{extractedAppFolder}";
	$SshInfo->{cmd} = "( $cmdUnlockKeychain; $cmdVerify1 ; $cmdVerify2 )";
	$ciomUtil->remoteExec($SshInfo);
	checkCodeSignFromLog();
}

sub checkCodeSignFromLog() {
	my $code = $OrgInfo->{code};
	my $appId = $AppCertData->{$code}->{appId};
	my $output = readpipe("tail -n 15 $jobLogFile");
	my $identifier;
	$appId =~ s/^.+?[.]//;
	$identifier = "Identifier=$appId";
	if ($output =~ /$identifier/){
		$OrgInfo->{codeSignVerifyStatus} = "pass";
	}
	
}

sub packageIpa() {
	if ($OrgInfo->{codeSignVerifyStatus} eq 'pass' ) {
		$SshInfo->{cmd} = "cd $OrgInfo->{workspace}; zip -q -r $appWorkspaceOnSlave/$reCodeSignIpa Payload";
		$ciomUtil->remoteExec($SshInfo);
	}
	else {
		print "[CIOM.WARNING] Code Sign Verification not passed for org <$OrgInfo->{code}>, skip package ipa. \n";
	}
}

sub exportEnterpriseIpa() {
	my $cmdExportIpa = generateExportIpaCmd("Enterprise");
	$SshInfo->{cmd} = "( $cmd2Workspace; $cmdUnlockKeychain; $cmdExportIpa )";
	$ciomUtil->remoteExec($SshInfo);
}

sub exportAppStoreIpa() {
	my $cmdExportIpa = generateExportIpaCmd("App-Store");
	$SshInfo->{cmd} = "( $cmd2Workspace; $cmdUnlockKeychain; $cmdExportIpa )";
	$ciomUtil->remoteExec($SshInfo);
}

sub initial4Org($){
	my $code = $_[0];
	$OrgInfo->{code} = $code;
	$OrgInfo->{certInfo} = $AppCertData->{$code};
	if (defined($CiomData->{orgs}->{$code}->{type})){
		$OrgInfo->{type} = $CiomData->{orgs}->{$code}->{type};
		if ($OrgInfo->{type} eq 'appstore') {
			$OrgInfo->{workspace} = $appstoreWs ;
		}
		else {
			$OrgInfo->{workspace} = $enterpriseWs ;
		}
	}
	else {
		$OrgInfo->{type} = "enterprise";
		$OrgInfo->{workspace} = $enterpriseWs ;
	}
	$OrgInfo->{codeSignVerifyStatus} = "" ;
	$OrgInfo->{extractedAppFolder} = "$OrgInfo->{workspace}/Payload/$BuildInfo->{typeTargetName}.app";
}

sub calOrgTypesCount() {
	for (my $i = 0; $i < $orgCount; $i++) {
		my $code = $need2BuildOrgCodes->[$i];
		if (defined($CiomData->{orgs}->{$code}->{type})) {
			if ($CiomData->{orgs}->{$code}->{type} eq 'appstore') {
				$appstoreOrgCount++ ;
			}
			else {
				$appstoreOrgCount++ ;
			}
		}
		else {
			$enterpriseOrgCount++ ;
		}	
	}
}

sub achiveAndExportIpa() {
	calOrgTypesCount();
	#### archive and export for enterprise ###
	if ( $enterpriseOrgCount > 0){
		archivePackage();
		exportEnterpriseIpa();
		backupEnterpriseArchive();
	}
	### archive and export for appstore ipa ###
	if ( $appstoreOrgCount > 0) {
		preActionForArchiveAppStorePackage();
		archivePackage();
		exportAppStoreIpa();
		backupAppStoreArchive();
	}
		
	### extract ipa ###
	extractIpa();
}

sub updateResourceAndPackage($) {
	my $code = $_[0];
	initial4Org($code);
	updateEntitlementsPlist();
	removeCodeSign();
	replaceOrgCustomizedFilesToSlave();
	replaceEntitlementsPlist();
	replaceMobileProvision();
	remoteStreameditConfs4Org();
	reCodeSign();
	verifyCodeSign();
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
	my $orgIpaFile = "$ENV{$slaveENV}/ws${wsId}/$version/$cloudId/$appName/$reCodeSignIpa";
	$ciomUtil->exec("mv $orgIpaFile $ApppkgPath/$appFinalPkgName");
}

sub cleanAfterOrgBuild() {
	;
}



