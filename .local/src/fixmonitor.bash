#!/bin/bash

monitor="$(get-monitor-sys edid | while read f; do cat $f | edid2id ; done | sort -h | sed 's/$/;/g' | xargs echo | sed 's/; /;/g' | sed 's/;$//')"

case "$monitor"
in
    "2000000")
       xrandr --output DP-1 --off --output DP-2 --off --output DP-3 --off --output DP-4 --off --output eDP-1 --primary
    ;;

    # My desk at home
    "2000000;40171551020;40173541020")
        xrandr --output DP-3 --auto --right-of eDP-1 --primary --output DP-4 --auto --right-of DP-3
    ;;

    # Rivos Desk
    "2000000;168555574824;168555574831")
    	xrandr --output DP-2 --auto --right-of eDP-1 --primary --output DP-1 --auto --right-of DP-2
    ;;

    *)
        echo "Unknown monitor configuration: $monitor"
        exit 1
    ;;
esac
