#!/bin/bash
#
source ./ciom.util.sh

host=$1
port=${2:-22}

javaEnvShell="/home/tech/ciom/java.sh"
local_policy='./jdk/1.7/local_policy.jar'
US_export_policy='./jdk/1.7/US_export_policy.jar'
remoteJdkHome='/usr/java/jdk1.7.0_76'

upload $javaEnvShell $host $port /etc/profile.d
upload $local_policy $host $port $remoteJdkHome/jre/lib/security
upload $US_export_policy $host $port $remoteJdkHome/jre/lib/security