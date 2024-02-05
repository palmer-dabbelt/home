#!/bin/bash

set -ex

repo="$HOME/work/palmer-notes/"

ldap="$(mhng-pipe-from "$@" | sed 's/@rivosinc.com//')"
if [[ "$ldap" == "" ]]
then
    echo "no LDAP provided"
    exit 1
fi

date="$(date +@%s -d"$(mhng-pipe-header Date "$@")")"

case "$ldap"
in
    greg)            ldap="gkm"       ;;
    vineet)          ldap="vineetg"   ;;
    kevin)           ldap="kevinl"    ;;
    clement)         ldap="cleger"    ;;
    alex)            ldap="alexghiti" ;;
<<<<<<< Updated upstream
    edwin)           ldap="ewlu"      ;;
=======
>>>>>>> Stashed changes
    *@embecosm.com)  ldap="embecosm";;
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
    ewlu)      human="Edwin Lu"           ;;
    kevinl)    human="Kevin Lee"          ;;
    charlie)   human="Charlie Jenkins"    ;;
    cleger)    human="Clément Léger"      ;;
    alexghiti) human="Alexandre Ghiti"    ;;
<<<<<<< Updated upstream
=======
    embecosm)  human="Embecosm";;
>>>>>>> Stashed changes
    *) echo "unknown human $ldap"; exit 1 ;;
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

mhng-repl "$@"
