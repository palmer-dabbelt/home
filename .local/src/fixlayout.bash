#!/bin/bash

style="code"
if [[ "$1" != "" ]]
then
    style="$1"
fi

monitor="$(get-monitor-sys edid | while read f; do cat $f | edid2id ; done | sort -h | sed 's/$/;/g' | xargs echo | sed 's/; /;/g' | sed 's/;$//')"

case "$monitor"
in
    # Just my laptop monitor, in case I'm on the couch
    "2000000")
        case "$style"
        in
            "code")
                awesome-client 'require("awful").tag.setnmaster(0)'
                awesome-client 'require("awful").tag.setncol(2)'
            ;;

            b*)
                awesome-client 'require("awful").tag.setnmaster(1)'
                awesome-client 'require("awful").tag.setncol(1)'
            ;;

            *)
                echo "Unknown style: $style"
                exit 1
            ;;
        esac
    ;;

    # My laptop when plugged into my desk at home or work -- they're exactly
    # the same size/resolution, so they should just match.
    "2000000;40171551020;40173541020"|"2000000;168555574824;168555574831")
        case "$style"
        in
            "code")
                awesome-client 'require("awful").tag.setnmaster(0)'
                awesome-client 'require("awful").tag.setncol(4)'
            ;;

            b*)
                awesome-client 'require("awful").tag.setnmaster(1)'
                awesome-client 'require("awful").tag.setncol(2)'
            ;;

            *)
                echo "Unknown style: $style"
                exit 1
            ;;
        esac
    ;;

    *)
        echo "Unknown monitor configuration: $monitor"
        exit 1
    ;;
esac
