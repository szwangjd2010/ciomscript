#!/bin/bash
ip=$1 
eval "ssh root@$ip \
$CIOM_SCRIPT_HOME/change.htpasswd.sh \
'$AccountName' '$OldPassword' '$NewPassword'"