#!/bin/bash

repo="$HOME/work/palmer-notes/"

ldap="$1"
if [[ "$ldap" == "" ]]
then
    echo "no LDAP provided"
    exit 1
fi

case "$ldap"
in
    greg)     ldap="gkm";;
    vineet)  ldap="vineetg";;
esac

case "$ldap"
in
    palmer)    human="Palmer Dabbelt" ;;
    preames)   human="Philip Reames" ;;
    collison)  human="Michael Collison" ;;
    gkm)       human="Greg McGary" ;;
    vineetg)   human="Vineet Gupta" ;;
    nelson)    human="Nelson Chu" ;;
    *) echo "u  nknown human $ldap"; exit 1;;
esac

file="$repo"/"$ldap"-"$(date +%Y-%m-%d)".md

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

vim +"normal G o" "$file"

while [[ "$(tail -1 "$file")" == "* " || "$(tail -1 "$file")" == "" ]]
do
    sed '$ d' -i "$file"
done

git -C "$repo" add "$(basename "$file")"
git -C "$repo" commit --no-gpg-sign "$(basename "$file")" -m "automatic commit from $0"
if [[ "$(nmcli g | grep ^connected | wc -l)" == "1" ]]
then
    git -C "$repo" pull --rebase
    git -C "$repo" push
fi
