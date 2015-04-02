#!/bin/bash
#

CiomShare='/data/ciomshare'

mountCiomShare() {
	mount //10.10.68.205/ciomshare /data/ciomshare -o username=root,password=ciomYXT123
}

changeGateway() {
	echo "change gateway..."
	perl -i -pE 's|(GATEWAY=)(.*)|${1}10.10.73.151|mg' /etc/sysconfig/network-scripts/ifcfg-eth0
}

changeMaxOpenFile() {
	echo "change max open file number permanently..."
	echo '* soft nofile 102400' >> /etc/security/limits.conf
	echo '* hard nofile 102400' >> /etc/security/limits.conf
	echo 'session    required     pam_limits.so' >> /etc/pam.d/login 
}

installJDK() {
	echo "install JDK..."
	rpm -ivh $CiomShare/jdk-7u76-linux-x64.rpm
}

patchJDK() {
	echo "patch jdk security..."
	javaProfileShell="$CiomShare/java.sh"
	local_policy="$CiomShare/local_policy.jar"
	US_export_policy="$CiomShare/US_export_policy.jar"
	jdkHome='/usr/java/jdk1.7.0_76'	
	/bin/cp -rf $javaProfileShell /etc/profile.d/
	/bin/cp -rf $local_policy $jdkHome/jre/lib/security/
	/bin/cp -rf $US_export_policy $jdkHome/jre/lib/security/
}

main() {
	#mountCiomShare
	changeMaxOpenFile
	changeGateway
	installJDK
	patchJDK
}

main