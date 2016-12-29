#!/bin/bash

topic=${1:-yxt.qida.action}
/sdb/kafka_2.11-0.10.0.0/bin/kafka-console-consumer.sh --zookeeper 172.17.128.99:2181 --topic $topic
