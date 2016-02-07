#!/bin/bash

if [[ "$TMUX" != "" ]]
then
	tmux split-window -h "exec bash"
fi
