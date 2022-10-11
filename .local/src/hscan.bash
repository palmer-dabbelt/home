#!/bin/bash

N=1
if [[ "$1" == "-N" ]]
then
    N="$2"
    shift 2
fi

G="cat"
if [[ "$1" == "--grep" ]]
then
    G="grep -i $2"
    shift 2
fi

exec mhng-pipe-scan_pretty "$@" | tail -n+$N | $G | head -n$(tput lines)
