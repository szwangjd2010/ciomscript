#!/usr/bin/python

import uuid
import redis

r = redis.Redis(host='172.17.128.227', port=6379, db=0)

for i in range(0, 10000000):
	k = "kkk" + str(i)
	v = str(uuid.uuid4())
	r.set(k, v)