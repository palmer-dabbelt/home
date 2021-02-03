#!/bin/bash

find -L /sys/class/drm/card*-* -maxdepth 1 -name status | while read f
do
    if [[ "$(cat $f)" == "connected" ]]
    then
        if test -f "$(dirname $f)/$1"
        then
            echo "$(dirname $f)/$1"
        fi
    fi
done
