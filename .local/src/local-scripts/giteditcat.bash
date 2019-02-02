#!/bin/bash

set -e

tempdir="$(mktemp -d /tmp/giteditcat.XXXXXXXX)"
trap "rm -rf $tempdir" EXIT

unset last
while [[ "$1" != "" ]]
do
    cat "$1" >> "$tempdir"/all
    last="$1"
    shift
done

mv "$tempdir"/all "$last"
rm -rf "$tempdir"

vim "$last"
