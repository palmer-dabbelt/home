#!/bin/bash

repo="$HOME/work/palmer-notes/"

when="@$(date +%s)"
vim="true"
while [[ "$1" != "" ]]
do
    case "$1"
    in
        "--when")  when="$2";     shift 2;;
        "--novim") vim="false";   shift 1;;
        *) break;;
    esac
done

ldap="$1"
if [[ "$ldap" == "" ]]
then
    echo "no LDAP provided"
    exit 1
fi

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
    david)           ldap="davidltl"  ;;
>>>>>>> Stashed changes
    *@embecosm.com)  ldap="embecosm"  ;;
esac

case "$ldap"
in
<<<<<<< Updated upstream
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
=======
    palmer)    human="Palmer Dabbelt"      ;;
    preames)   human="Philip Reames"       ;;
    gkm)       human="Greg McGary"         ;;
    vineetg)   human="Vineet Gupta"        ;;
    nelson)    human="Nelson Chu"          ;;
    patrick)   human="Patrick O'Neill"     ;;
    andrea)    human="Andrea Parri"        ;;
    edwin)     human="Edwin Lu"            ;;
    kevinl)    human="Kevin Lee"           ;;
    charlie)   human="Charlie Jenkins"     ;;
    cleger)    human="Clément Léger"       ;;
    alexghiti) human="Alexandre Ghiti"     ;;
    embecosm)  human="Embecosm"            ;;
    davidlt)   human="David Abdurachmanov" ;;
>>>>>>> Stashed changes
    *) echo "unknown human $ldap"; exit 1 ;;
esac

file="$repo"/"$ldap"-"$(date +%Y-%m-%d -d$when)".md

if [[ "$(nmcli g | grep ^connected | wc -l)" == "1" ]]
then
    git -C "$repo" pull --rebase
fi

if ! test -f "$file"
then
    cat >"$file" <<EOF
# ${human}'s Notes for $(date "+%B %e, %Y" -d$when)

EOF
fi

if [[ "$vim" == true ]]
then
    vim +"normal G o" "$file"
else
    cat >> "$file"
fi

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
