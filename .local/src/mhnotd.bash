#!/bin/bash

set -ex

repo="$HOME/work/palmer-notes/"

ldap="$(mhng-pipe-from "$@" | sed 's/@rivosinc.com//')"
if [[ "$ldap" == "" ]]
then
    echo "no LDAP provided"
    exit 1
fi

case "$ldap"
in
    *@embecosm.com)  ldap="embecosm";;
esac

date="$(date +@%s -d"$(mhng-pipe-header Date "$@")")"

case "$ldap"
in
    palmer)    human="Palmer Dabbelt" ;;
    preames)   human="Philip Reames" ;;
    collison)  human="Michael Collison" ;;
    gkm)       human="Greg McGary" ;;
    vineetg)   human="Vineet Gupta" ;;
    nelson)    human="Nelson Chu" ;;
    kevinl)    human="Kevin Lee" ;;
    patrick)   human="Patrick O'Neill" ;;
    embecosm)  human="Embecosm";;
    *) echo "u  nknown human $ldap"; exit 1;;
esac

file="$repo"/"$ldap"-"$(date +%Y-%m-%d -d"$date")".md

if [[ "$(nmcli g | grep ^connected | wc -l)" == "1" ]]
then
    git -C "$repo" pull --rebase
fi

if ! test -f "$file"
then
    cat >"$file" <<EOF
# ${human}'s Notes for $(date "+%B %e, %Y")

EOF
fi

mhng-body "$@" >> "$file"

git -C "$repo" add "$(basename "$file")"
git -C "$repo" commit --no-gpg-sign "$(basename "$file")" -m "automatic commit from $0"
if [[ "$(nmcli g | grep ^connected | wc -l)" == "1" ]]
then
    git -C "$repo" pull --rebase
    git -C "$repo" push
fi
