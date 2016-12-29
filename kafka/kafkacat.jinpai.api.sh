#!/bin/bash
#

Broker=10.10.23.164
Topic=yxt.jinpai.api

one() {
    tail -F /data/ws-[1-4]/tomcat7-1/logs/yxt/qidaapi_event.log \
        | grep -P '^\w{8}-' \
        | kafkacat -b $Broker -t $Topic &
}

multi() {
    for i in 1 2; do
        tail -F /data/ws-$i/tomcat7-1/logs/yxt/qidaapi_event.log \
            | kafkacat -b $Broker -t $Topic &
    done
}

method=${1:-multi}
echo $method
${method}
