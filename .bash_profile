# Enable all bash completions
source ~/.local/share/bash-completion/bash_completion

# Use my local programs
export PATH="$HOME/.local/bin:$PATH"

# Setup my personal shell variables that are the same everywhere
export EDITOR="e"
alias no=ls

# Some shell variables are different on different machines
export MAKEFLAGS="-j$(cat /proc/cpuinfo | grep ^processor | wc -l)"

# A nicer-looking prompt
if test -f /usr/bin/mhng-bud
then
    export PS1="\[\e[0;0m\e[32m\]\u \[\e[31m\]\h \[\e[34m\]\W \[\e[1;31m\]\`mhng-bud\`\[\e[0;32m\]\\$\[\e[0m\] "
else
    export PS1="\[\e[0m\e[32m\]\u \[\e[31m\]\h \[\e[34m\]\W \[\e[32m\]\\$\[\e[0m\] "
fi

# I want everything in my .bashrc loaded, since it's all useful
source $HOME/.bashrc
