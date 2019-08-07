#!/bin/bash

# I always want the devtoolset stuff on RedHat
if test -e /opt/rh/devtoolset-2/enable
then
    source /opt/rh/devtoolset-2/enable
fi

if test -e /tools/support/lsf/conf/profile.lsf
then
    source /tools/support/lsf/conf/profile.lsf
fi

# Enable all bash completions
source ~/.local/share/bash-completion/bash_completion

# When the shell exits, append to the history file instead of overwriting it
shopt -s histappend

# Use my local programs
export PATH="$HOME/.local/bin:$PATH"
export PKG_CONFIG_PATH="$HOME/.local/lib/pkgconfig:$PKG_CONFIG_PATH"

# Some machines don't have proper terminfo databases
export TERMINFO="$HOME/.local/share/terminfo"

# Setup my personal shell variables that are the same everywhere
export EDITOR="e"
export BROWSER="chromium"
export GIT_EDITOR="vim"
export MHNG_EDITOR="vim"
export TERMINAL="kitty"
alias no=ls
alias caly='cal -Y'

# MH aliases
alias hscan="mhng-scan | head -50"
alias scan="mhng-scan"
alias scanl="mhng-scan | less"
alias inbox="mhng-scan inbox"
alias rss="mhng-scan rss"
alias lists="mhng-scan lists"
alias promo="mhng-scan promo"
alias drafts="mhng-scan drafts"
alias sent="mhng-scan sent"
alias trash="mhng-scan trash"
alias lkml="mhng-scan linux"
alias upstream="mhng-scan upstream"
alias linux="mhng-scan linux"
alias patches="mhng-scan patches"
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
alias gmail="$BROWSER \"https://mail.google.com/mail/u/0/#search/rfc822msgid=\$(mhng-pipe-header message-id | sed 's/<\(.*\)>/\1/' | sed 's/\+/%2B/g' | sed 's@/@%2F@g')\""
alias lkml="$BROWSER \"https://lkml.kernel.org/r/\$(mhng-pipe-header message-id | sed 's/<\(.*\)>/\1/' | sed 's/\+/%2B/g' | sed 's@/@%2F@g')\""
alias mal="mhng-hud"
alias mhng-log="tail -n40 ~/.mhng/daemon.log"

# Aliases to "cd ../../.. ..."
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

# Other aliases
alias todo='$GIT_EDITOR ~/TODO'
alias bwrcfont='printf '"'"'\33]50;%s\007'"'"' "xft:Liberation Mono-7"'
alias bigfont='printf '"'"'\33]50;%s\007'"'"' "xft:Liberation Mono-20"'
alias startw='weston-launch -- --modules=xwayland.so'
alias ix="curl -F 'f:1=<-' ix.io"

# Some shell variables are different on different machines
export MAKEFLAGS="-j$(cat /proc/cpuinfo | grep ^processor | wc -l)"

# Zathura doesn't support GDK_SCALE
alias zathura='GDK_SCALE=1 zathura'

# Setup my environment variables for this tree
alias enter='source $(findenter)'
alias renter='source $(findrenter)'

# A nicer-looking prompt
if test -S $HOME/.mhng/daemon.socket
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

# I want address sanitizer to output stack traces
export ASAN_SYMBOLIZER_PATH=/usr/bin/llvm-symbolizer
export ASAN_OPTIONS=symbolize=1

# Attempt to setup a keychain
if test -x $HOME/.local/bin/keychain
then
	mkdir -p $HOME/.local/var/keychain

	if test -x /usr/bin/ssh-agent
	then
		find $HOME/.ssh -iname "id_*" | grep -v ".pub$" | xargs \
		$HOME/.local/bin/keychain \
			--agents ssh \
			--confhost \
			--dir $HOME/.local/var/keychain \
			--quiet
	fi

	if test -x /usr/bin/gpg-agent
	then
		$HOME/.local/bin/keychain \
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
