#!/bin/bash
#
source $CIOM_SCRIPT_HOME/ciom.util.sh
setMode ${1:-0}

net=172.17.128.
#net=hdc-

for (( i=50; i<=70; i++ )); do
	if (( $i == 59 )); then
		continue
	fi
	ip=$net$i
	#$CIOM_SCRIPT_HOME/auto.interact.ssh.with.key.exp $ip
	#execRemoteCmd $ip 22 "echo 10 > /proc/sys/vm/swappiness"
	#execRemoteCmd $ip 22 "echo 'vm.swappiness = 10' >> /etc/sysctl.conf"
	#execRemoteCmd $ip 22 "echo never > /sys/kernel/mm/transparent_hugepage/defrag"
	#execRemoteCmd $ip 22 "echo 'echo never > /sys/kernel/mm/transparent_hugepage/defrag' >> /etc/rc.local"	
	#execRemoteCmd $ip 22 "yum install krb5-workstation -y"	
	#execRemoteCmd 172.17.128.50 22 "ssh $ip 'rm -rf /user; mkdir -p /usr/share/java/'; scp /usr/share/java/mysql-connector-java.jar $ip:/usr/share/java/"	
	#execCmd "rsync -avp /etc/krb5.conf $ip:/etc/"
	execRemoteCmd $ip 22 "systemctl stop ntpd; ntpdate -s time.gist.gov; systemctl start ntpd; rdate -s time.gist.gov;systemctl status ntpd"	
	#execRemoteCmd $ip 22 "halt -p &"	
done