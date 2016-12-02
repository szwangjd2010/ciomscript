#!/bin/bash
#

one() {
    tail -F /data/ws-[1-2]/tomcat7-1/logs/yxt/qidaapi_event.20161125.log \
        | grep -P '^\w{8}-1' \
        | kafkacat -b 10.10.23.164 -t yxt.qida.api.event &
}

multi() {
    for i in 1 2; do
        tail -F /data/ws-$i/tomcat7-1/logs/yxt/qidaapi_event.20161125.log \
            | kafkacat -b 10.10.23.164 -t yxt.qida.api.event &
    done
}

method=${1:-multi}
echo $method
${method}
