#!/bin/bash

monitor="$(get-monitor-sys edid | while read f; do cat $f | edid2id ; done | sort -h | sed 's/$/;/g' | xargs echo | sed 's/; /;/g' | sed 's/;$//')"

case "$monitor"
in
    "700001")
    	xrandr --output DP-1 --off --output DP-2 --off --output DP-1-2 --off --output DP-2-2 --off
	xrandr --output eDP-1 --auto --primary --scale 0.5x0.5
    ;;

    "700001;227111110")
    	xrandr --output DP-1 --auto --primary --left-of eDP-1
    ;;

    "700001;1000049;40171551020")
        xrandr --output eDP-1 --scale 0.5x0.5 --pos 3840x0 --output DP-1-2 --auto --pos 0x540 --scale 1x1 --primary --output DP-2 --auto --pos 3840x1620 --scale 0.5x0.5
        xrandr --output eDP-1 --scale 0.5x0.5 --pos 3840x0 --output DP-2-2 --auto --pos 0x540 --scale 1x1 --primary --output DP-1 --auto --pos 3840x1620 --scale 0.5x0.5
	xautolock -disable
    ;;

    *)
        echo "Unknown monitor configuration: $monitor"
        exit 1
    ;;
esac
