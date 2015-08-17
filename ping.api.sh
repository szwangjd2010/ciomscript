#!/bin/bash


hosts="10.10.73.235 10.10.76.73 10.10.75.138"
ports="8080 8081 8082 8083"

pingapi() {
	host=$1
	port=$2

	echo $host:$port
	time curl http://$host:$port/v1/serverstatus --connect-timeout 3
	echo 	
}

while [ True ]; do
	for host in $hosts; do
		for port in $ports; do
			pingapi $host $port
		done
	done
done
