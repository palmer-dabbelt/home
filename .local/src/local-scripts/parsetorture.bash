#!/bin/bash

tempdir=$(mktemp -d parse-torture.XXXXXX)
trap "rm -rf $tempdir" EXIT


if [[ "$1" == "--listregs" ]]
then
    cat "$2" | sed 's@^\(................\)\(................\)$@\2\n\1@' | head -n64
    exit 0
fi

if [[ "$1" == "--listfregs" ]]
then
    $0 --listregs $2 | tail -n+33  | grep -n "" | head -n32 | while read l
    do
        i="$(echo "$l" | cut -d: -f1)"
        v="$(echo "$l" | cut -d: -f2)"
        echo "$((i - 1)):$v"
    done | sed s@^@f@
    exit 0
fi

if [[ "$1" == "--listxregs" ]]
then
    $0 --listregs $2 | tail -n+1  | grep -n "" | head -n32 | while read l
    do
        i="$(echo "$l" | cut -d: -f1)"
        v="$(echo "$l" | cut -d: -f2)"
        echo "$((i - 1)):$v"
    done | sed s@^@x@
    exit 0
fi

if [[ "$1" == "--diffregs" ]]
then
    $0 --listxregs $2 > /tmp/$(basename $2)
    $0 --listxregs $3 > /tmp/$(basename $3)
    diff -u /tmp/$(basename $2) /tmp/$(basename $3)
    $0 --listfregs $2 > /tmp/$(basename $2)
    $0 --listfregs $3 > /tmp/$(basename $3)
    diff -u /tmp/$(basename $2) /tmp/$(basename $3)
fi
