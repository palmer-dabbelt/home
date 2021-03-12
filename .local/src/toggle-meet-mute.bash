#!/bin/bash

prev="$(xdotool getactivewindow)"
meet="$(xdotool search --name "Meet - ")"

if [[ "${meet}" != "" ]]
then
    xdotool windowactivate --sync "${meet}"
    xdotool key "Control_L+d"
    xdotool windowactivate "${prev}"
fi
