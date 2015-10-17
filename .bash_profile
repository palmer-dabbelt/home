# Enable all bash completions
source ~/.local/share/bash-completion/bash_completion

# Use my local programs
export PATH="$HOME/.local/bin:$PATH"

# Setup my personal shell variables that are the same everywhere
export EDITOR="e"
alias no=ls

# Some shell variables are different on different machines
export MAKEFLAGS="-j$(cat /proc/cpuinfo | grep ^processor | wc -l)"

# I want everything in my .bashrc loaded, since it's all useful
source $HOME/.bashrc
