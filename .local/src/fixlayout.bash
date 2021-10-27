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
    "700001")
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


    # Google desk monitor, which is 32" 4K.  My home desk monitor, a slightly
    # smaller 28" 4K screen is also listed here.
    "700001;1000049;40171551020"|"700001;40171551020"|"700001;227111110")
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
