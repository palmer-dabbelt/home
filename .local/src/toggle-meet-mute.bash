#!/bin/bash

prev="$(xdotool getactivewindow)"
meet="$(xdotool search --name "Meet - ")"
yt="$(xdotool search --name "YouTube")"

if [[ "${meet}" != "" ]]
then
    xdotool windowactivate --sync "${meet}"
    xdotool key "Control_L+d"
    xdotool windowactivate "${prev}"
elif [[ "${yt}" != "" ]]
then
    xdotool windowactivate --sync "${yt}"
    xdotool key "space"
    xdotool windowactivate "${prev}"
fi
