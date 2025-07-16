#!/bin/bash

set -x

# Move stuff over from my camcorder
find /Volumes/Untitled -name "*.MXF" | while read mxf
do
    date="$(ffprobe "$mxf" 2>&1 | grep modification_date | cut -d: -f2- | sort | uniq | xargs echo)"
    ymd="$(date -j -u -z "America/Los_Angeles" -f "%Y-%m-%dT%H:%M:%S.000000Z" "$date" +"%Y-%m-%d")"
    hms="$(date -j -u -z "America/Los_Angeles" -f "%Y-%m-%dT%H:%M:%S.000000Z" "$date" +"%Y-%m-%d-%H-%M-%S")"
    folder="/Volumes/MacOS Scratch/Videos/"
    xml="$(echo "$mxf" | sed "s/.MXF/M01.XML/g")"
    mkdir -p "$folder"
    echo "Copying \"$mxf\" to \"$folder\""
    yes | fs52yt "$mxf" "$folder"/"$hms".mp4 || exit 1
    rm "$mxf" "$xml"
done

diskutil eject /Volumes/Untitled
