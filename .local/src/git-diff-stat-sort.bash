# From https://gist.github.com/jakub-g/7599177
git diff "$@" --stat=200 | tail +7 | awk '{ print $3 " "$4 " " $1}' | sort -n -r | less
