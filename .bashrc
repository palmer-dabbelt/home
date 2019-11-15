#!/bin/bash

if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# Attempts to start keychain
eval `keychain --eval --agents ssh --inherit any --quiet id_rsa`

# When the shell exits, append to the history file instead of overwriting it
shopt -s histappend

# I've got a bunch of stuff that's necessary for my own local packages in here.
export PATH="$HOME/.local/bin:$PATH"

# Setup my personal shell variables that are the same everywhere
export EDITOR="e"
export BROWSER="google-chrome-stable"
export GIT_EDITOR="vim"
export MHNG_EDITOR="vim"
export TERMINAL="urxvt"
alias no=ls
alias ix="curl -F 'f:1=<-' ix.io"
alias su="sudo --login"
alias enter="source enter.bash"

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
alias gmail="$BROWSER \"https://mail.google.com/mail/u/0/#search/rfc822msgid=\$(mhng-pipe-header message-id | sed 's/<\(.*\)>/\1/' | sed 's/\+/%2B/g' | sed 's@/@%2F@g')\""
alias lkml="$BROWSER \"https://lkml.kernel.org/r/\$(mhng-pipe-header message-id | sed 's/<\(.*\)>/\1/' | sed 's/\+/%2B/g' | sed 's@/@%2F@g')\""

# Aliases to "cd ../../.. ..."
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

# Some shell variables are different on different machines
export MAKEFLAGS="-j$(cat /proc/cpuinfo | grep ^processor | wc -l)"

# A nicer-looking prompt
if test -S $HOME/.mhng/daemon.socket
then
    export PS1="\[\e[0;0m\e[32m\]\u \[\e[31m\]\h \[\e[34m\]\W \[\e[1;31m\]\`mhng-bud\`\[\e[0;32m\]\\$\[\e[0m\] "
else
    export PS1="\[\e[0m\e[32m\]\u \[\e[31m\]\h \[\e[34m\]\W \[\e[32m\]\\$\[\e[0m\] "
fi

# I want address sanitizer to output stack traces
export ASAN_SYMBOLIZER_PATH=/usr/bin/llvm-symbolizer
export ASAN_OPTIONS=symbolize=1
