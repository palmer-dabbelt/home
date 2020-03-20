#!/bin/bash

tags=""
if [[ "$1" == "--reviewed-by" ]]
then
    tags="${tags}r"
    shift
fi

mhng-pipe-scan "$@" | sort -k 4 | cut -d' ' -f1 | while read seqnum
do
    if test -e ./scripts/checkpatch.pl
    then
        mhng-pipe-show_stdout "$seqnum" | ./scripts/checkpatch.pl
    fi

    mhng-pipe-show_stdout "$seqnum" | grep -ve "^Cc" | git am -3S

    mhng-pipe-show_stdout "$seqnum" --thread | grep -e "^Reviewed-by: " | while read tag
    do
        echo "Adding $tag"
        git add-tag "$tag"
    done

    tag "$tags" | while read tag
    do
        echo "Adding $tag"
        git add-tag "$tag"
    done

    (
        export GIT_EDITOR=true
        git commit --amend -s --quiet
    )
done
