#!/bin/bash

style="code"
if [[ "$1" != "" ]]
then
    style="$1"
fi

case "$(cat /sys/class/drm/card0-DP-1/edid | edid2id)"
in
    # No monitor attached,
    "")
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

    # Google desk monitor, which is 32" 4K
    "227111110")
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

    # Home desk, which is also 4K but physically smaller and therefor gets a
    # zoom applied to it because DPI-based font scaling doesn't appear to work
    # at all.  This also applies to the smaller Google desk monitors.
    "226000024")
        case "$style"
        in
            "code")
                awesome-client 'require("awful").tag.setnmaster(0)'
                awesome-client 'require("awful").tag.setncol(3)'
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


    *)
        echo "Unknown monitor: $(cat /sys/class/drm/card0-DP-1/edid | edid2id)"
        exit 1
    ;;
esac
