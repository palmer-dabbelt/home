#!/bin/bash

set -ex
monitor="$(get-monitor-sys edid | sort | while read f; do echo "$(basename $(dirname $f)):$(cat $f | edid2id)" ; done | sed 's/$/;/g' | xargs echo | sed 's/; /;/g' | sed 's/;$//')"

case "$monitor"
in
    # Just the internal monitor on my laptap
    "card0-eDP-1:2000000")
       xrandr --output DP-1 --off --output DP-2 --off --output DP-3 --off --output DP-4 --off --output eDP-1 --primary
    ;;

    # The two monitors on my desk at home, when plugged into my Rivos laptop.
    "card0-DP-1:40173541020;card0-DP-2:40171551020;card0-eDP-1:2000000")
        xrandr --output DP-3 --off --output DP-4 --off
        xrandr --output DP-2 --auto --right-of eDP-1 --primary --output DP-1 --auto --right-of DP-2
    ;;

    "card0-DP-1:40171551020;card0-DP-2:40173541020;card0-eDP-1:2000000")
        xrandr --output DP-3 --off --output DP-4 --off
        xrandr --output DP-1 --auto --right-of eDP-1 --primary --output DP-2 --auto --right-of DP-1
    ;;

    "card0-DP-3:40173541020;card0-DP-4:40171551020;card0-eDP-1:2000000")
    	xrandr --output DP-1 --off --output DP-2 --off
        xrandr --output DP-4 --auto --right-of eDP-1 --primary --output DP-3 --auto --right-of DP-4
    ;;

    "card0-DP-4:40173541020;card0-DP-3:40171551020;card0-eDP-1:2000000")
    	xrandr --output DP-1 --off --output DP-2 --off
        xrandr --output DP-3 --auto --right-of eDP-1 --primary --output DP-4 --auto --right-of DP-3
    ;;

    # Rivos Desk
    "card0-DP-1:168555574824;card0-DP-2:168555574831;card0-eDP-1:2000000")
        xrandr --output DP-2 --auto --right-of eDP-1 --primary --output DP-1 --auto --right-of DP-2
    ;;

    "")
        xrandr --output DP-1 --off --output DP-2 --off
        xrandr --output DP-4 --auto --right-of eDP-1 --primary --output DP-3 --auto --right-of DP-4
    ;;


    *)
        echo "Unknown monitor configuration: $monitor"
        exit 1
    ;;
esac
