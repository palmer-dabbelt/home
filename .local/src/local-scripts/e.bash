#!/bin/bash

if [[ "$DISPLAY" != "" ]]
then
	while [[ "$1" != "" ]]
	do
		urxvt -e vim "$(readlink -f $1)" &
		shift
	done
elif [[ "$TMUX" != "" ]]
then
	tmux split-window -h "exec vim $(readlink -f $1)"
else
	vim "$@"
fi
