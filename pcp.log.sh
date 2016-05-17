#!/bin/bash
#
source $CIOM_SCRIPT_HOME/log.common.sh "$@"

$CIOM_SCRIPT_HOME/pull.log.sh "$@"
$CIOM_SCRIPT_HOME/clean.log.sh "$@"
$CIOM_SCRIPT_HOME/put.log.into.hdfs.sh "$@"
