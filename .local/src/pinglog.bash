#!/bin/bash

while true
do
    (
        tmp="$(mktemp)"
        count=50

        ping -A -c $count www.google.com >& "$tmp"

        line="$(cat "$tmp" | grep "packets transmitted")"
        start="$(date +%s)"
        loss="$(echo "$line" | sed 's/.* \([.0-9]*\)% packet loss, .*/\1/')"
        time="$(echo "$line" | sed 's/.* \([.0-9]*\)ms/\1/')"

        line="$(cat "$tmp" | grep "^rtt")"
        min="$(echo "$line" | sed 's@.* = \([.0-9]*\)/\([.0-9]*\)/\([.0-9]*\)/\([.0-9]*\) ms.*@\1@')"
        avg="$(echo "$line" | sed 's@.* = \([.0-9]*\)/\([.0-9]*\)/\([.0-9]*\)/\([.0-9]*\) ms.*@\2@')"
        max="$(echo "$line" | sed 's@.* = \([.0-9]*\)/\([.0-9]*\)/\([.0-9]*\)/\([.0-9]*\) ms.*@\3@')"
        mdv="$(echo "$line" | sed 's@.* = \([.0-9]*\)/\([.0-9]*\)/\([.0-9]*\)/\([.0-9]*\) ms.*@\4@')"

        echo "$start $loss $time $count $min $avg $max $mdv" | flock -x ping.log tee --append ~/ping.log

        rm -f "$tmp"
    ) &
    sleep 1s
done
