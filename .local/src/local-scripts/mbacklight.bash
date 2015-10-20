#!/bin/bash

SENSOR_MAX=50
SENSOR_MIN=1
BACKLIGHT_MAX=100
BACKLIGHT_MIN=10
ADJUST_TIME=$((10 * 1000))
ADJUST_STEPS=$((ADJUST_TIME / 100))

if test ! -e /sys/devices/platform/applesmc.768/light
then
	echo "No Apple backlight"
	exit 1
fi

if [[ "$(cat /proc/acpi/button/lid/LID0/state)" != "state:      open" ]]
then
	exit 0
fi

sensor="$(cat /sys/devices/platform/applesmc.768/light | sed 's/(\([0-9]*\),[0-9]*)/\1/')"
backlight="$((BACKLIGHT_MIN + (BACKLIGHT_MAX - BACKLIGHT_MIN) * (sensor - SENSOR_MIN) / (SENSOR_MAX - SENSOR_MIN)))"
xbacklight -set $backlight -time $ADJUST_TIME -steps $ADJUST_STEPS
