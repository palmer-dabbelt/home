#!/bin/bash

if [[ "$WAYLAND_DISPLAY" == "" ]]
then
    /usr/bin/slock
else
    swaylock
fi
