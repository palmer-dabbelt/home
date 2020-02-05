#!/bin/bash

(
    while true
    do
        hexchat
        sleep 10s
    done
) &

(
    while true
    do
        telegram-desktop
        sleep 10s
    done
) &

( google-chrome --profile-directory="Default" --app=http://chat.google.com ) &

wait
