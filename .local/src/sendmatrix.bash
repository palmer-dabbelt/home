#!/bin/bash

while read f
do
    window="$(xdotool search --name "Element")"
    echo "$f" | xclip
    xdotool mousemove --sync --window "${window}" 1900 500
    xdotool click 2
    xdotool key "Return"
    sleep 10s
done
