#!/bin/bash

unset full
unset edit_file
while [[ "$1" != "" ]]
do
    case "$1" in
    "Acked-by: "*|"Reviewed-by: "*|"Signed-off-by: "*|"Tested-by: "*|"Link: "*|"Fixes: "*|"Cc: "*|"Reported-by: "*)
        full="$1"
        shift 1
    ;;

    "--edit-file")
        edit_file="$2"
        shift 2
    ;;

    *)
    	full="$(tag $1)"
	shift 1
    ;;
    esac
done

# Edit the given file to add the given tag at the end.
if [[ "$edit_file" != "" ]]
then
    # Delete any trailing whitespace.
    while [[ "$(tail -1 "$edit_file")" == "* " || "$(tail -1 "$edit_file")" == "" ]]
    do
        sed '$ d' -i "$edit_file"
    done

    if [[ "$(cat "$edit_file" | grep -e "^${full}$" | wc -l)" == 0 ]]
    then
        echo "$full" >> "$edit_file"
    fi

    exit 0
fi

# We're in the normal mode, so just add the given tag.
tag="$(echo "$full" | cut -d: -f1)"
who="$(echo "$full" | cut -d: -f2-)"

(
    export GIT_EDITOR="$0 '$full' --edit-file"
    git commit --amend --quiet --no-status
)
