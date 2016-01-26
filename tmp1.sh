#!/bin/bash

ip=${1:-10.10.73.181}
w3root=${2:-/data/}

(cd lecaih5mobile; zip -r ../html.zip *)
scp html.zip root@$ip:$w3root
ssh root@$ip "mkdir -p ${w3root}lecaih5mobile; cd ${w3root}lecaih5mobile; rm -rf *; cp ../html.zip ./; unzip ./html.zip"
