#!/bin/bash

set -ex

merge=""
sob="-s"
link="-l"
merge_base=""
while [[ "$1" != "" ]]
do
    case "$1" in
    "--merge")        merge="-M";                                shift 1;;
    "--no-merge")     merge="";                                  shift 1;;
    "--merge-base")   merge_base="--merge-base=$2"; merge="-M";  shift 2;;
    [A-za-z0-9]*|"--")                 break;;
    *) exit "$0: unknown argument $1"; exit 1;;
    esac
done

mhng-pipe-scan "$@" | sort -k 4 | cut -d' ' -f1 | while read seqnum
do
    if [[ "$(mhng-pipe-header Subject $seqnum | grep "GIT PULL" | wc -l)" != 0 ]]
    then
    	y b4 --no-interactive pr --nostdin "$(mhng-pipe-header Message-ID $seqnum)"
	y git merge FETCH_HEAD --no-edit || (git add . && y git commit --no-edit)
	GIT_EDITOR=without-choice y git commit --amend -s
    else
    	y b4 --no-interactive shazam -t $merge $merge_base $sob $link "$(mhng-pipe-header Message-ID $seqnum)"
    fi
done
