#!/bin/bash
#
#

source $CIOM_SCRIPT_HOME/ciom.util.sh
source $CIOM_SCRIPT_HOME/ciom.mysql.util.sh

dump "172.17.128.231" 3306 root pwdasdwx lecai2
dump "172.17.128.231" 3306 root pwdasdwx mall
dump "172.17.128.231" 3306 root pwdasdwx qida
dump "172.17.128.231" 3306 root pwdasdwx component
dump "172.17.128.231" 3306 root pwdasdwx darkhorse


dump "172.17.128.237" 3306 root pwdasdwx jira
dump "172.17.128.237" 3306 root pwdasdwx confluence