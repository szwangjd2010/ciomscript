#!/bin/bash
# 
#
if [ "$Password" == "woyaobusuXX" ]; then
	touch "$WORKSPACE/__auth_success"
fi

if [ "$Passwordv2" == "woyaobusuXXXXv2" ]; then
	touch "$WORKSPACE/__auth_success"
fi

if [ "$PasswordRestartTomcat" == "woyaorestarttomcat" ]; then
	touch "$WORKSPACE/__auth_success"
fi
