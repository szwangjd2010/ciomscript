#!/bin/bash
#
YHDC_SCRIPT_HOME=$CIOM_SCRIPT_HOME/yhdc
source $YHDC_SCRIPT_HOME/log.common.sh "$@"

$YHDC_SCRIPT_HOME/pull.log.sh "$@"
$YHDC_SCRIPT_HOME/clean.log.sh "$@"
$YHDC_SCRIPT_HOME/put.log.into.hdfs.sh "$@"
$YHDC_SCRIPT_HOME/refresh.impala.metadata.sh
