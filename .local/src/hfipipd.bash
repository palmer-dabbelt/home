#!/bin/bash

while true
do
    date
    if [[ "$(ssh-add -lq | wc -l)" != 0 ]]
    then
        hfipip
    else
        echo "No SSH keys added"
    fi
    abssleep $((45 + RANDOM % 30))
done
