#!/bin/bash
# 


target=$1
password=$2
srcPath=$3
srcFile=${4:-"*"}

cd $srcPath
zip -P $password@pwdasdwx -r $target $srcFile
