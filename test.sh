#!/bin/bash
# 
#

a=$1
b=$2
c=${3:-v1}
echo $a
echo $b
echo $c

_t1() {
	echo _t1
}

_t1
