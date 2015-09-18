#!/bin/bash
# 
#
if [ "$CiomPassphrase" == "prestableV2" ]; then
	exit 0
fi

if [ "$CiomPassphraseCeping" == "ceping" ]; then
	exit 0
fi

exit 1