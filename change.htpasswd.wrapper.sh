#!/bin/bash

eval "ssh root@172.17.127.72 \
/tech/user/micro/ciom/change.htpasswd.sh \
'$AccountName' '$OldPassword' '$NewPassword'"