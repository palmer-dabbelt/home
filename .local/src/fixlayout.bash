#!/bin/bash

style="code"
if [[ "$1" != "" ]]
then
    style="$1"
fi

case "$(cat $(get-monitor-sys edid) | edid2id)"
in
    # No monitor attached,
    ""|"600001")
        case "$style"
        in
            "code")
                awesome-client 'require("awful").tag.setnmaster(0)'
                awesome-client 'require("awful").tag.setncol(2)'
            ;;

            *)
                echo "Unknown style: $style"
                exit 1
            ;;
        esac
    ;;

    # Google desk monitor, which is 32" 4K.  My home desk monitor, a slightly
    # smaller 28" 4K screen is also listed here.
    "227111110"|"40171551020")
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

    # Smaller Google desk monitors.
    "226000024")
        case "$style"
        in
            "code")
                awesome-client 'require("awful").tag.setnmaster(0)'
                awesome-client 'require("awful").tag.setncol(3)'
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
        echo "Unknown monitor: $(cat $(get-monitor-sys edid) | edid2id)"
        exit 1
    ;;
esac
