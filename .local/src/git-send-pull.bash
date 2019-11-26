#!/bin/bash

set -e

function join_by { local IFS="$1"; shift; echo "$*"; }

from="$(git var -l | grep ^GIT_COMMITTER_IDENT | cut -d= -f2- | cut -d'>' -f1)>"
to=()
cc=()
unset style
unset parent
unset repo
unset tag

while [[ "$1" != "" ]]
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
    --style)
        style="$2"
        shift
        shift
        ;;
    --parent)
        parent="$2"
        shift
        shift
        ;;
    --repo)
        repo="$2"
        shift
        shift
        ;;
    --tag)
        tag="$2"
        shift
        shift
        ;;
    *)
        echo "unknown argument $1" >&2
        exit 1
        ;;
    esac
done

if [[ "$1" == "--" ]]
then
    shift
else
    echo
fi

unset 

tempdir="$(mktemp -d /tmp/git-send-pull.XXXXXXXX)"
trap "rm -rf $tempdir" EXIT

subject="$(git request-pull "$parent" "$repo" "$tag" | sed -n '/^----------------------------------------------------------------$/ { s///; :a; n; p; ba; }' | head -n1)"

case "$style" in
"qemu")
    echo "Subject: [PULL] $subject" >> $tempdir/message
    echo "" >> $tempdir/message
    ;;
"linux")
    echo "From: $from" >> $tempdir/message
    echo "To: $(join_by , "${to[@]}")" >> $tempdir/message
    echo "CC: $(join_by , "${cc[@]}")" >> $tempdir/message
    echo "Subject: [GIT PULL] $subject" >> $tempdir/message
    echo "" >> $tempdir/message
    ;;
*)
    echo "Unknown style $style" >&2
    exit 1
    ;;
esac

git request-pull "$parent" "$repo" "$tag" >> $tempdir/message

# FIXME: There should be a --no-show-signature option to 'git request-pull'
sed '/^gpg: /d' -i $tempdir/message

# FIXME: There should be an option for no insteadof in 'git request-pull'
git config -l | grep -e '^url[.].*[.]insteadof=.*$' | while read sub
do
    from="$(echo "$sub" | sed 's/^url[.]\(.*\)[.]insteadof=\(.*\)$/\1/')"
    to="$(echo "$sub" | sed 's/^url[.]\(.*\)[.]insteadof=\(.*\)$/\2/')"
    sed "s!${from}!${to}!" -i $tempdir/message
done

case "$style" in
"linux")
    $GIT_EDITOR $tempdir/message
    mhng-pipe-comp_stdin < $tempdir/message
    ;;
"qemu")
    export GIT_EDITOR="giteditcat $tempdir/message"
    git send-email --subject-prefix="PULL" --to "$(join_by , "${to[@]}")" --cc "$(join_by , "${cc[@]}")" --compose "$parent".."$tag"
    ;;
esac
