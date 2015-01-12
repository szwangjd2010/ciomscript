#!/bin/bash
#

password='x5nYeUOw'
while read item; do
	array=(${item// / })
	echo "./auto.ssh-copy-id.to.exp ${array[0]} ${array[1]} $password"
	
done < guoke.vm.list.2