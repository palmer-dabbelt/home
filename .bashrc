#!/bin/bash

# GPG won't use curses-askpass unless I set this variable
if [[ "$SSH_TTY" != "$GPG_TTY" ]]
then
	export GPG_TTY="$SSH_TTY"
fi

# Attempt to setup a keychain
if test -x /usr/bin/keychain
then
	find .ssh -iname "id_*" | grep -v ".pub$" | xargs \
	keychain \
		--agents gpg,ssh \
		--confhost \
		--dir $HOME/.local/var/keychain \
		--quiet
fi

if test -r $HOME/.local/var/keychain/$HOSTNAME-sh
then
	source $HOME/.local/var/keychain/$HOSTNAME-sh
fi

if test -r $HOME/.local/var/keychain/$HOSTNAME-sh-gpg
then
        source $HOME/.local/var/keychain/$HOSTNAME-sh-gpg
fi
