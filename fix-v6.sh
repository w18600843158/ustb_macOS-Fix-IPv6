#!/usr/bin/env sh

# get active interface
INTERFACE=$(route get google.com | awk '/interface:/{print $2}')
# reset first
sudo ipconfig set $INTERFACE automatic-v6
sleep 0.5
# get ip/prefix length/default router
IP=$(ifconfig | awk '/inet6 .*autoconf/{print $2}')
PREFIX_LEN=$(ifconfig | awk '/inet6 .*autoconf/{print $4}')
echo "IP:        $IP/$PREFIX_LEN"
echo "Interface: $INTERFACE"

ROUTER=$(traceroute6 -m 1 bt.byr.cn 2>/dev/null | awk '{print $2}')
echo "Router:    $ROUTER"
# manual set IP 
sudo ifconfig $INTERFACE inet6 $IP/$PREFIX_LEN
# restart interface
sudo ifconfig $INTERFACE down
sleep 0.5
sudo ifconfig $INTERFACE up
# manual add default route
sudo route add -inet6 -prefixlen 0 default $ROUTER
