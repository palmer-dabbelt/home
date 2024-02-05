#!/bin/bash

if [ -f $HOME/.bashrc_local ]; then
    . $HOME/.bashrc_local
fi

# Attempts to start keychain
alias kc='eval `keychain --eval --agents ssh,gpg --inherit any id_rsa`'

# When the shell exits, append to the history file instead of overwriting it
shopt -s histappend

# I've got a bunch of stuff that's necessary for my own local packages in here.
export PATH="$HOME/.local/bin:$PATH"

# Setup my personal shell variables that are the same everywhere
export EDITOR="e"
export BROWSER="browser"
export GIT_EDITOR="vim"
export MHNG_EDITOR="vim"
export TERMINAL="kitty"
alias no=ls
alias ix="curl -F 'f:1=<-' ix.io"
alias su="sudo --login"
alias enter="source enter.bash"
alias gerp=grep
alias make="nice -n10 ionice -c3 make"
alias watch='watch --color'

# MH aliases
alias scan="mhng-scan"
alias scanl="mhng-scan | less -R"
alias inbox="mhng-scan inbox"
alias rss="mhng-scan rss"
alias lists="mhng-scan lists"
alias promo="mhng-scan promo"
alias drafts="mhng-scan drafts"
alias sent="mhng-scan sent"
alias trash="mhng-scan trash"
alias upstream="mhng-scan upstream"
alias linux="mhng-scan linux"
alias patches="mhng-scan patches"
alias post="mhng-post"
alias rmm="mhng-rmm"
alias rrmm="mhng-rmm riscv"
alias mime="mhng-mime"
alias show="mhng-show"
alias showk="k mhng-show"
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
alias gmail="$BROWSER --user \$(mhng-pipe-imap_account_name) -- \"https://mail.google.com/mail/u/0/#search/rfc822msgid=\$(mhng-pipe-header message-id | sed 's/<\(.*\)>/\1/' | sed 's/\+/%2B/g' | sed 's@/@%2F@g')\""
alias lkml="$BROWSER \$(make-lore-link)"
alias gsml="$BROWSER \$(make-gccpatches-link)"
alias bsml="$BROWSER \$(make-binutils-link)"
alias lsml="$BROWSER \$(make-libcalpha-link)"
alias ctp='ssh palmer.ba.rivosinc.com "cat patch"'
alias gko="$BROWSER \$(make-gitkernelorg-link)"

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
