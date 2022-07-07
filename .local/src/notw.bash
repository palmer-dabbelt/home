#!/bin/bash

repo="$HOME/work/notes/"

project=boss
if [[ "$1" != "" ]]
then
    project="$1"
fi

date="$(date +%s)"
file="$repo"/"$project"-"$(date +%Y-%m-%d)".md

if [[ "$(nmcli g | grep ^connected | wc -l)" == "1" ]]
then
    git -C "$repo" pull --rebase
fi

if ! test -f "$repo"/"$project".children
then
    echo "Unknown project children: $repo/$project.children"
    exit 1
fi
children="$repo"/"$project".children

cat "$children" | while read c
do
    $TERMINAL $0 $c
done

# Check for all the necessary files
if test ! -f "$repo"/"$project".keywords
then
    echo "Unknown project keywords: $repo/$project.keywords"
    exit 1
fi
keywords=()
readarray -t keywords < "$repo"/"$project".keywords

if test ! -f "$repo"/"$project".parents
then
    echo "Unknown project parents: $repo/$project.parents"
    exit 1
fi
parents=()
readarray -t parents < "$repo"/"$project".parents

if test ! -f "$repo"/"$project".title
then
    echo "Unknown project title: $repo/$project.title"
    exit 1
fi
title="$(cat "$repo"/"$project".title)"

if ! test -f "$file"
then
    cat >"$file" <<EOF
# ${title} for $(date "+%B %e, %Y")

EOF
fi

(
    (
        for keyword in "${keywords[@]}"
        do
            for delta in $(seq -w 0 500)
            do
                day="$(date -d "$delta days ago" +%Y-%m-%d)"
		for parent in "${parents[@]}"
		do
                    find "$repo" -name "${parent}"-"${day}".md | xargs grep -l "$keyword"
		done

		if test "$delta" -eq "0"
		then
		    continue
		fi

                if test -f "$repo"/"$project"-"$day".md
                then
                    break
                fi
            done
        done
    ) | sort | while read note
    do
        cat "$note" | sed 's/^#/##/' >> "$file"
    done
)

vim +"normal o" "$file"

wait

while [[ "$(tail -1 "$file")" == "* " || "$(tail -1 "$file")" == "" ]]
do
    sed '$ d' -i "$file"
done

if [[ "$(cat "$file" | wc -l)" == 0 ]]
then
    rm -f "$file"
    echo "Empty file, bailing out"
    exit 1
fi

git -C "$repo" add "$(basename "$file")"
git -C "$repo" commit --no-gpg-sign "$(basename "$file")" -m "automatic commit from $0"
if [[ "$(nmcli g | grep ^connected | wc -l)" == "1" ]]
then
    git -C "$repo" pull --rebase
    git -C "$repo" push
fi
