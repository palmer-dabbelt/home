#!/bin/bash

if [[ "$DISPLAY" != "" ]]
then
	urxvt -e vim "$(readlink -f $1)"
else
	vim "$1"
fi
