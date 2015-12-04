#!/bin/bash

uptime=$(date -d yesterday "+%Y%m%d"000000)
echo $uptime
qs="apikey=f75e1b15-698a-4031-995f-88d9f3d70318&salt=1441720242&signature=c1861fe5fd3d883f2cadf30ffa67ff6fb9aa52715b6ab175b3851dbc2617a318&uptime=$uptime"

urlPrefix="http://lecaiapi.yunxuetang.cn:8080/qidaimapi/v1/integration"

curl "$urlPrefix/syncorg?$qs"
sleep 600
curl "$urlPrefix/syncjob?$qs"
sleep 600
curl "$urlPrefix/syncuser?$qs"
