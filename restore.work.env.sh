#!/bin/bash
#
source $CIOM_SCRIPT_HOME/ciom.util.sh

execRemoteCmd 172.17.128.236 22 "/opt/nexus-2.11.0-02/bin/nexus start"

execRemoteCmd 172.17.128.234 22 "/opt/ws-1/tomcat7-1/bin/startup.sh"
execRemoteCmd 172.17.128.234 22 "/opt/ws-2/tomcat7-1/bin/startup.sh"
execRemoteCmd 172.17.128.234 22 "/opt/ws-3/tomcat7-1/bin/startup.sh"
execRemoteCmd 172.17.128.234 22 "/opt/ws-4/tomcat7-1/bin/startup.sh"
execRemoteCmd 172.17.128.234 22 "/opt/ws-5/tomcat7-1/bin/startup.sh"
execRemoteCmd 172.17.128.234 22 "/opt/ws-6/tomcat7-1/bin/startup.sh"

execRemoteCmd 172.17.128.232 22 "/opt/ws-1/tomcat7-1/bin/startup.sh"
execRemoteCmd 172.17.128.232 22 "/opt/ws-2/tomcat7-1/bin/startup.sh"
execRemoteCmd 172.17.128.232 22 "/opt/ws-3/tomcat7-1/bin/startup.sh"
execRemoteCmd 172.17.128.232 22 "/opt/ws-4/tomcat7-1/bin/startup.sh"
execRemoteCmd 172.17.128.232 22 "/opt/ws-5/tomcat7-1/bin/startup.sh"
execRemoteCmd 172.17.128.232 22 "/opt/ws-6/tomcat7-1/bin/startup.sh"

execRemoteCmd 172.17.128.150 22 "/opt/ws-1/tomcat7-1/bin/startup.sh"
execRemoteCmd 172.17.128.150 22 "/opt/ws-2/tomcat7-1/bin/startup.sh"
execRemoteCmd 172.17.128.150 22 "/opt/ws-3/tomcat7-1/bin/startup.sh"
execRemoteCmd 172.17.128.150 22 "/opt/ws-4/tomcat7-1/bin/startup.sh"

execRemoteCmd 172.17.128.225 22 "/opt/ws-1/tomcat7-1/bin/startup.sh"
execRemoteCmd 172.17.128.225 22 "/opt/ws-2/tomcat7-1/bin/startup.sh"
execRemoteCmd 172.17.128.225 22 "/opt/ws-3/tomcat7-1/bin/startup.sh"
execRemoteCmd 172.17.128.225 22 "/opt/ws-4/tomcat7-1/bin/startup.sh"

execRemoteCmd 172.17.128.221 22 "/opt/ws-1/tomcat7-1/bin/startup.sh"
execRemoteCmd 172.17.128.221 22 "/opt/ws-2/tomcat7-1/bin/startup.sh"
execRemoteCmd 172.17.128.221 22 "/opt/ws-3/tomcat7-1/bin/startup.sh"
execRemoteCmd 172.17.128.221 22 "/opt/ws-4/tomcat7-1/bin/startup.sh"

execRemoteCmd 172.17.128.222 22 "/opt/ws-1/tomcat7-1/bin/startup.sh"
execRemoteCmd 172.17.128.222 22 "/opt/ws-2/tomcat7-1/bin/startup.sh"
execRemoteCmd 172.17.128.222 22 "/opt/ws-3/tomcat7-1/bin/startup.sh"
execRemoteCmd 172.17.128.222 22 "/opt/ws-4/tomcat7-1/bin/startup.sh"

execRemoteCmd 172.17.128.152 22 "/opt/ws-1/tomcat7-1/bin/startup.sh"
execRemoteCmd 172.17.128.152 22 "/opt/ws-2/tomcat7-1/bin/startup.sh"
execRemoteCmd 172.17.128.152 22 "/opt/ws-3/tomcat7-1/bin/startup.sh"
execRemoteCmd 172.17.128.152 22 "/opt/ws-4/tomcat7-1/bin/startup.sh"

execRemoteCmd 172.17.128.237 22 "/opt/crowd272/start_crowd.sh" 
execRemoteCmd 172.17.128.237 22 "/opt/atlassian-confluence-5.3.1/bin/start-confluence.sh"
execRemoteCmd 172.17.128.237 22 "/opt/jira/bin/start-jira.sh"

execRemoteCmd 172.17.128.233 22 "/opt/ws-1/tomcat7-1/bin/startup.sh"
execRemoteCmd 172.17.128.233 22 "/opt/ws-2/tomcat7-1/bin/startup.sh"
