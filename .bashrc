#!/bin/bash

# GPG won't use curses-askpass unless I set this variable
if [[ "$SSH_TTY" != "$GPG_TTY" ]]
then
	export GPG_TTY="$SSH_TTY"
fi
