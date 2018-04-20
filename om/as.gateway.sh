#!/bin/bash
#

echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -F
iptables -t filter -F

iptables -t nat -A POSTROUTING -s 172.17.128.0/24 -d 10.10.0.0/16 -o tun0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.17.128.0/24 -d 10.200.0.0/16 -o tun0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o tun0 -j ACCEPT
