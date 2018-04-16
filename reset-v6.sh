#!/usr/bin/env sh
INTERFACE=$(route get google.com | awk '/interface:/{print $2}'
sudo ipconfig set $INTERFACE automatic-v6
