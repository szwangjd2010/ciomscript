#!/bin/bash

eval "ssh root@172.17.120.247 \
/tech/user/micro/ciom/change.htpasswd.sh \
'$AccountName' '$OldPassword' '$NewPassword'"