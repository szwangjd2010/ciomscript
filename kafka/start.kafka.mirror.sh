#!/bin/bash

cd /sdb/kafka_2.11-0.10.0.0
./bin/kafka-mirror-maker.sh \
	--consumer.config config/consumer.properties \
	--producer.config config/producer.properties \
	--whitelist "^yxt\.[\w\.]+$"

