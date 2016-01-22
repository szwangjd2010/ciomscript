#!/bin/bash
#

hostsFile=$1
password=$2
while read item; do
	echo "./auto.ssh-copy-id.to.exp ${array[0]} ${array[1]} $password"
	
done < $hostsFile