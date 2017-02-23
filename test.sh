#!/bin/bash
# 
#

string='My string';

if [[ "$string" =~ .*My.* ]];
then
   echo "It's there!"
fi
