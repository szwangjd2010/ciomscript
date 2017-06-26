#!/bin/bash
#

PatternIsCating="tail -F /data/ws-[1-3]/tomcat7-1/logs/yxt/qidaapi_event.log"

is_cating() {
    cnt=$(pgrep -l -f "$PatternIsCating" | wc -l)
    if [ $cnt -eq 3 ]; then
	echo -n 1
    fi
    
    echo -n 0
}

kill_cating() {
    pkill -9 -f "$PatternIsCating"
}

if [ $(is_cating) = 0 ]; then
    echo "cating is abnormal..."
    echo "kill cating..."
    kill_cating
    sleep 5
    echo "start cating..."
else
    echo "already in-cating..."
    exit 0
fi

Broker=10.10.23.164
Topic=yxt.qida.api.event

one() {
    tail -F /data/ws-[1-3]/tomcat7-1/logs/yxt/qidaapi_event.log \
        | grep -P '^\w{8}-' \
        | kafkacat -b $Broker -t $Topic &
}

multi() {
    for i in 1 2 3; do
        tail -F /data/ws-$i/tomcat7-1/logs/yxt/qidaapi_event.log \
            | kafkacat -b $Broker -t $Topic &
    done
}

method=${1:-multi}
echo $method
${method}
