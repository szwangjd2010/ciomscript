#!/bin/bash

eval "ssh root@172.17.127.72 \
$CIOM_SCRIPT_HOME/change.htpasswd.sh \
'$AccountName' '$OldPassword' '$NewPassword'"