#!/bin/bash

if [[ "$1" == "-C" ]]
then
    cd "$2"
    shift 2
fi

kitty "$@" &
