#!/bin/bash

repo="$HOME/work/notes/"

ldap=palmerdabbelt
human="Palmer Dabbelt"

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

echo "* $(date +%l:%M): " >> "$file"

vim +"normal G A" "$file"

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
