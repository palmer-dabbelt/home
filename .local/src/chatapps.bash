#!/bin/bash

(
    while true
    do
        nheko
        sleep 10s
    done
) &

(
    google-chrome --profile-directory="Default" &
    sleep 10s
    google-chat
) &

wait
