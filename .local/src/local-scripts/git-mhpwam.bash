#!/bin/bash

set -e
set -o pipefail

args=()
if [[ "$1" == "-p" ]]
then
    args+=("$1" "$2")
    shift 2
else
    echo "$0: -p <project> ..."
    exit 1
fi

mhng-pipe-scan "$@" | sort -k 4 | cut -d' ' -f1 | while read seqnum
do
    mhng-pipe-header Message-ID "$seqnum" \
        | xargs pwclient list "${args[@]}" -m \
        | grep "^[0-9]" \
        | cut -d' ' -f1 \
        | xargs pwclient git-am "${args[@]}" -3 -s

done
