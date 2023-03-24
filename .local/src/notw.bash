#!/bin/bash

in_repo="$HOME/work/palmer-notes/"
ot_repo="$HOME/work/rivos-notes/"

project="$1"
if [[ "$project" == "" ]]
then
    echo "no project provided"
    exit 1
fi

case "$project"
in
    t*)     project="toolchain" ;;
    b*)     project="boss" ;;
    *) echo "unknown project $project"; exit 1;;
esac

if [[ "$project" == "boss" ]]
then
    ot_repo="$in_repo"
fi

date=""
case "$project"
in
    toolchain)    date="@$(date +%s -d "9am this thursday")" ;;
    boss)         date="@$(date +%s -d "9am this friday")" ;;
    *)            date="@$(date +%s)" ;;
esac
file="$ot_repo"/"$project"-"$(date +%Y-%m-%d -d "$date")".md

if [[ "$(nmcli g | grep ^connected | wc -l)" == "1" ]]
then
    git -C "$in_repo" pull --rebase
    git -C "$ot_repo" pull --rebase
fi

if ! test -f "$ot_repo"/"$project".children
then
    echo "Unknown project children: $ot_repo/$project.children"
    exit 1
fi
children="$ot_repo"/"$project".children

cat "$children" | while read c
do
    $TERMINAL $0 $c
done

# Check for all the necessary files
if test ! -f "$ot_repo"/"$project".keywords
then
    echo "Unknown project keywords: $ot_repo/$project.keywords"
    exit 1
fi
keywords=()
readarray -t keywords < "$ot_repo"/"$project".keywords

if test ! -f "$ot_repo"/"$project".parents
then
    echo "Unknown project parents: $ot_repo/$project.parents"
    exit 1
fi
parents=()
readarray -t parents < "$ot_repo"/"$project".parents

if test ! -f "$ot_repo"/"$project".title
then
    echo "Unknown project title: $ot_repo/$project.title"
    exit 1
fi
title="$(cat "$ot_repo"/"$project".title)"

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
                    find "$in_repo" -name "${parent}"-"${day}".md | xargs grep -l "$keyword"
		done

		if test "$delta" -eq "0"
		then
		    continue
		fi

                if test -f "$ot_repo"/"$project"-"$day".md
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

git -C "$ot_repo" add "$(basename "$file")"
git -C "$ot_repo" commit --no-gpg-sign "$(basename "$file")" -m "automatic commit from $0"
if [[ "$(nmcli g | grep ^connected | wc -l)" == "1" ]]
then
    git -C "$ot_repo" pull --rebase
    git -C "$ot_repo" push
fi
