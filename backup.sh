#!/bin/bash

timestamp=$(date +%04Y%02m%02d)
scp -P 50011 root@222.92.116.85:/root/utils/backup/workspace/nest-$timestamp.tar.gz /tech/user/micro/backup/
scp -P 50011 root@222.92.116.85:/root/utils/backup/workspace/tigase-$timestamp.tar.gz /tech/user/micro/backup/
