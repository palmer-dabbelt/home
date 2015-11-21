#!/bin/bash

if [[ "$DISPLAY" != "" ]]
then
	urxvt -e vim "$(readlink -f $1)" &
elif [[ "$TMUX" != "" ]]
then
	tmux split-window -h "exec vim $(readlink -f $1)"
else
	vim "$1"
fi
