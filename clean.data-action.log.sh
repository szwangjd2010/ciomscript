#!/bin/bash
#

#clear log4j prefix
perl -i -pE 's/^.+ \[\w+\.java:\d+\] - //g' $1
