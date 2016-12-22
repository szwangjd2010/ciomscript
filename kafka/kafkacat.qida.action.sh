#!/bin/bash
#

Broker=10.10.23.164
Topic=yxt.qida.action

one() {
    tail -F /data/ws-[1-2]/tomcat7-1/logs/yxt/qida_action.log \
        | grep -P '^\w{8}-' \
        | kafkacat -b $Broker -t $Topic &
}

multi() {
    for i in 1 2 3 4; do
        tail -F /data/ws-$i/tomcat7-1/logs/yxt/qida_action.log \
            | kafkacat -b $Broker -t $Topic &
    done
}

method=${1:-multi}
echo $method
${method}