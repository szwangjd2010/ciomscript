#!/bin/bash
#

#clear log4j prefix
perl -i -pE 's/^.+ \[\w+\.java:\d+\] - //g' $1
perl -i -pE 's/(^"|"$|(?<=\t)"|"(?=\t))//g' $1
