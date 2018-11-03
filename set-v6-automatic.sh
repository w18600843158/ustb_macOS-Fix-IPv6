#!/usr/bin/env sh

services_raw=$(networksetup -listnetworkserviceorder | tail -n +2)
# remove \n in services_raw
services=$(echo $services_raw | sed "s/(\([0-9]\))/\\\n/g")

while read line; do
    sname=$(echo $line | sed "s/(\(.*\))//g" | sed "s/ $//g")
    sdev=$(echo $line | awk -F  "(,)|(: )|[)]" '{print $4}')
    if [ -n "$sdev" ]; then
        ifout="$(ifconfig $sdev 2>/dev/null)"
        echo "$ifout" | grep 'status: active' > /dev/null 2>&1
        rc="$?"
        if [ "$rc" -eq 0 ]; then
            current_service="$sname"
            current_device="$sdev"
        fi
    fi
done <<< "$(echo "$services")"

if [ -n "$current_service" ]; then
    echo "Current Service: '$current_service'"
    echo "Current Device:  $current_device"
else
    >&2 echo "Could not find current service"
    exit 1
fi

method=$(networksetup -getinfo "$current_service" | grep "IPv6: " | sed "s/^IPv6: //")
echo "Current IPv6 Config: $method"

if [ "$method" != "Automatic" ]; then 
    echo "Reset to automatic..."
    networksetup -setv6automatic "$current_service"
    echo  "wait for address..."
    sleep 1;
fi