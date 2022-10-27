#!/bin/bash

set -e

merge=""
sob="-s"
link="-l"
while [[ "$1" != "" ]]
do
    case "$1" in
    "--merge")      merge="-M --merge-base $2";    shift 2;;
    "--no-merge")   merge="";                      shift 1;;
    [A-za-z0-9]*|"--")                             break;;
    esac
done

mhng-pipe-scan "$@" | sort -k 4 | cut -d' ' -f1 | while read seqnum
do
    if [[ "$(mhng-pipe-header Subject $seqnum | grep "GIT PULL" | wc -l)" != 0 ]]
    then
    	y b4 pr --nostdin "$(mhng-pipe-header Message-ID $seqnum)"
	y git merge FETCH_HEAD --no-edit || (git add . && y git commit --no-edit)
	GIT_EDITOR=without-choice y git commit --amend -s
    else
    	y b4 shazam $merge $sob $link "$(mhng-pipe-header Message-ID $seqnum)"
    fi
done
