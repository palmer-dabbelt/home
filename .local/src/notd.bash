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
    greg)    ldap="gkm"       ;;
    vineet)  ldap="vineetg"   ;;
    kevin)   ldap="kevinl"    ;;
    clement) ldap="cleger"    ;;
    alex)    ldap="alexghiti" ;;
esac

case "$ldap"
in
    palmer)    human="Palmer Dabbelt"     ;;
    preames)   human="Philip Reames"      ;;
    gkm)       human="Greg McGary"        ;;
    vineetg)   human="Vineet Gupta"       ;;
    nelson)    human="Nelson Chu"         ;;
    patrick)   human="Patrick O'Neill"    ;;
    andrea)    human="Andrea Parri"       ;;
    edwin)     human="Edwin Lu"           ;;
    kevinl)    human="Kevin Lee"          ;;
    charlie)   human="Charlie Jenkins"    ;;
    cleger)    human="Clément Léger"      ;;
    alexghiti) human="Alexandre Ghiti"    ;;
    *) echo "unknown human $ldap"; exit 1 ;;
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
