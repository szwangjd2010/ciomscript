#!/bin/bash

eval "ssh root@172.17.127.72 \
$CIOM_HOME/ciom/change.htpasswd.sh \
'$AccountName' '$OldPassword' '$NewPassword'"