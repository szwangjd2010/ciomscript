#!/bin/bash

timestamp=$(date +%04Y%02m%02d)
scp -P 50007 root@122.193.22.133:/storage/data/ciom.workspace/dbdump/exiaoxin-$timestamp.bz2 /tech/user/micro/backup/
scp -P 50007 root@122.193.22.133:/storage/data/ciom.workspace/dbdump/tigase-$timestamp.bz2 /tech/user/micro/backup/
