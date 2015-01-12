#!/usr/bin/python

import memcache
mc = memcache.Client(['122.193.22.133:11211'], debug=0)

mc.set("aaa", "Some value")
value = mc.get("aaa")
print mc.get("aaa")
mc.set("bbb", 3)
print mc.get("bbb")

