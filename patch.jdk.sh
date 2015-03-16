#!/bin/bash
#
source ./ciom.util.sh

port=$1

javaEnvShell="/home/tech/ciom/java.sh"
local_policy='./jdk/1.7/local_policy.jar'
US_export_policy='./jdk/1.7/US_export_policy.jar'
remoteJdkHome='/usr/java/jdk1.7.0_76'

upload $javaEnvShell 122.193.22.133 $port /etc/profile.d
upload $local_policy 122.193.22.133 $port $remoteJdkHome/jre/lib/security
upload $US_export_policy 122.193.22.133 $port $remoteJdkHome/jre/lib/security