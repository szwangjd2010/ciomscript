#!/bin/bash

(cd lecaih5mobile; zip -r ../html.zip *)
scp html.zip root@10.10.73.181:/data/
ssh root@10.10.73.181 "mkdir -p /data/lecaih5mobile; cd /data/lecaih5mobile; rm -rf *; cp ../html.zip ./; unzip ./html.zip"
