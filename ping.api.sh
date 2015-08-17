#!/bin/bash


hosts="10.10.73.235 10.10.76.73 10.10.75.138"

for host in $hosts; do
	for port in 8080 8081 8082 8083; do
		echo $host:$port
		time curl http://$host:$port/v1/serverstatus --connect-timeout 3
		echo 
	done
done


