#!/bin/bash

# Enable all bash completions
source ~/.local/share/bash-completion/bash_completion

# Use my local programs
export PATH="$HOME/.local/bin:$PATH"

# Setup my personal shell variables that are the same everywhere
export EDITOR="e"
export BROWSER="firefox"
export GIT_EDITOR="vim"
export MHNG_EDITOR="vim"
alias no=ls

# MH aliases
alias scan="mhng-scan"
alias inbox="mhng-scan inbox"
alias rss="mhng-scan rss"
alias lists="mhng-scan lists"
alias promo="mhng-scan promo"
alias drafts="mhng-scan drafts"
alias sent="mhng-scan sent"
alias trash="mhng-scan trash"
alias lkml="mhng-scan linux"
alias post="mhng-post"
alias rmm="mhng-rmm"
alias mime="mhng-mime"
alias show="mhng-show"
alias next="mhng-next"
alias prev="mhng-prev"
alias mtn="mhng-mtn"
alias mtp="mhng-mtp"
alias folders="mhng-folders"
alias urls="mhng-urls"
alias url="mhng-urls 1"
alias comp="mhng-comp"
alias forw="mhng-forw"
alias repl="mhng-repl"
alias detach="mhng-detach"
alias hud="watch mhng-hud"
alias gmail="firefox \"https://mail.google.com/mail/u/0/#search/rfc822msgid=\$(mhng-pipe-header message-id | sed 's/<\(.*\)>/\1/' | sed 's/\+/%2B/g')\""
alias mal="mhng-hud"
alias mhng-log="tail -n40 ~/.mhng/daemon.log"

# These are quick ways to access my common machines
alias hurricane='ssh bwrcrdsl-2.eecs.berkeley.edu -t "screen -x hurricane-chip"'

# Some shell variables are different on different machines
export MAKEFLAGS="-j$(cat /proc/cpuinfo | grep ^processor | wc -l)"

# A nicer-looking prompt
if test -f /usr/bin/mhng-bud
then
    export PS1="\[\e[0;0m\e[32m\]\u \[\e[31m\]\h \[\e[34m\]\W \[\e[1;31m\]\`mhng-bud\`\[\e[0;32m\]\\$\[\e[0m\] "
else
    export PS1="\[\e[0m\e[32m\]\u \[\e[31m\]\h \[\e[34m\]\W \[\e[32m\]\\$\[\e[0m\] "
fi

# GPG won't use curses-askpass unless I set this variable
if [[ "$SSH_TTY" != "$GPG_TTY" ]]
then
	export GPG_TTY="$SSH_TTY"
fi

# Attempt to setup a keychain
if test -x $HOME/.local/bin/keychain
then
	mkdir -p $HOME/.local/var/keychain

	if test -x /usr/bin/ssh-agent
	then
		find $HOME/.ssh -iname "id_*" | grep -v ".pub$" | xargs \
		keychain \
			--agents ssh \
			--confhost \
			--dir $HOME/.local/var/keychain \
			--quiet
	fi

	if test -x /usr/bin/gpg-agent
	then
		keychain \
			--agents gpg \
			--confhost \
			--dir $HOME/.local/var/keychain \
			--quiet
	fi
fi

if test -r $HOME/.local/var/keychain/$HOSTNAME-sh
then
	source $HOME/.local/var/keychain/$HOSTNAME-sh
fi

if test -r $HOME/.local/var/keychain/$HOSTNAME-sh-gpg
then
        source $HOME/.local/var/keychain/$HOSTNAME-sh-gpg
fi
