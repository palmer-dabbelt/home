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
    ldap="$(whoami)"
    exit 1
fi

case "$ldap"
in
    palmer)  ldap="palmerdabbelt"  ;;
esac

case "$ldap"
in
    palmer)    human="Palmer Dabbelt"     ;;
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
