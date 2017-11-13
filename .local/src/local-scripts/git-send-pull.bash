#!/bin/bash

from="$(git var -l | grep ^GIT_COMMITTER_IDENT | cut -d= -f2- | cut -d'>' -f1)>"
to=()
cc=()

while [[ "$1" != "--" ]]
do
    case "$1" in
    --to)
        to+=($(echo "$2" | sed 's/,/ /g'))
        shift
        shift
        ;;
    --cc)
        cc+=($(echo "$2" | sed 's/,/ /g'))
        shift
        shift
        ;;
    *)
        set -- -- "$@"
        ;;
    esac
done

if [[ "$1" == "--" ]]
then
    shift
fi

tempdir="$(mktemp -d /tmp/git-send-pull.XXXXXXXX)"
trap "rm -rf $tempdir" EXIT

echo "From: $from" > $tempdir/message

for x in ${to[*]}
do
  echo "To: $x" >> $tempdir/message
done

for x in ${cc[*]}
do
  echo "CC: $x" >> $tempdir/message
done

echo "Subject: [GIT PULL] $(git request-pull "$@" | sed -n '/^----------------------------------------------------------------$/ { s///; :a; n; p; ba; }' | head -n1)" >> $tempdir/message
echo "" >> $tempdir/message

git request-pull "$@" >> $tempdir/message

$GIT_EDITOR $tempdir/message

mhng-pipe-comp_stdin < $tempdir/message
