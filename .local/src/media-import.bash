#!/bin/bash

set -x

# Move stuff over from my camcorder
find /Volumes/Untitled -name "*.MXF" | while read mxf
do
    date="$(ffprobe "$mxf" 2>&1 | grep modification_date | cut -d: -f2- | sort | uniq | xargs echo)"
    ymd="$(date -j -u -z "America/Los_Angeles" -f "%Y-%m-%dT%H:%M:%S.000000Z" "$date" +"%Y-%m-%d")"
    hms="$(date -j -u -z "America/Los_Angeles" -f "%Y-%m-%dT%H:%M:%S.000000Z" "$date" +"%Y-%m-%d-%H-%M-%S")"
    xml="$(echo "$mxf" | sed "s/.MXF/M01.XML/g")"
    model="$(cat "$xml" | grep "<Device" | sed 's/.*modelName="\([A-Z0-9-]*\)".*/\1/')"
    folder="/Volumes/scratch/Videos/$model"
    mkdir -p "$folder"
    echo "Copying \"$mxf\" to \"$folder\""
    cp "$mxf" "$folder"/"$hms".mxf
    cp "$xml" "$folder"/"$hms".xml
done

find /Volumes/Untitled/PRIVATE -name "*.MP4" | while read mp4
do
    date="$(ffprobe "$mp4" 2>&1 | grep creation_time | cut -d: -f2- | sort | uniq | xargs echo)"
    ymd="$(date -j -u -z "America/Los_Angeles" -f "%Y-%m-%dT%H:%M:%S.000000Z" "$date" +"%Y-%m-%d")"
    hms="$(date -j -u -z "America/Los_Angeles" -f "%Y-%m-%dT%H:%M:%S.000000Z" "$date" +"%Y-%m-%d-%H-%M-%S")"
    xml="$(echo "$mp4" | sed "s/.MP4/M01.XML/g")"
    model="$(cat "$xml" | grep "<Device" | sed 's/.*modelName="\([A-Z0-9-]*\)".*/\1/')"
    folder="/Volumes/scratch/Videos/$model"
    mkdir -p "$folder"
    echo "Copying \"$mp4\" to \"$folder\""
    cp "$mp4" "$folder"/"$hms".mp4
    cp "$xml" "$folder"/"$hms".xml
done

find /Volumes/Untitled/DCIM -name "*RFPHH" | while read dir
do
    find "$dir" -name "*.MP4" | while read mp4
    do
        date="$(ffprobe "$mp4" 2>&1 | grep creation_time | cut -d: -f2- | sort | uniq | xargs echo)"
        ymd="$(date -j -u -z "America/Los_Angeles" -f "%Y-%m-%dT%H:%M:%S.000000Z" "$date" +"%Y-%m-%d")"
        hms="$(date -j -u -z "America/Los_Angeles" -f "%Y-%m-%dT%H:%M:%S.000000Z" "$date" +"%Y-%m-%d-%H-%M-%S")"
        folder="/Volumes/scratch/Videos/"
        mkdir -p "$folder"
        echo "Copying \"$mp4\" to \"$folder\""
	cp "$mp4" "$folder"/"$hms".mp4
	exit 1
    done
done

diskutil unmount /Volumes/Untitled

find ~/Downloads/scratch/ -name "GX*.MP4" | while read mp4
do
    date="$(ffprobe "$mp4" 2>&1 | grep creation_time | cut -d: -f2- | sort | uniq | xargs echo)"
    ymd="$(date -j -u -z "America/Los_Angeles" -f "%Y-%m-%dT%H:%M:%S.000000Z" "$date" +"%Y-%m-%d")"
    hms="$(date -j -u -z "America/Los_Angeles" -f "%Y-%m-%dT%H:%M:%S.000000Z" "$date" +"%Y-%m-%d-%H-%M-%S")"
    folder="/Volumes/scratch/Videos/"
    mv "$mp4" "$folder"/"$hms".mp4 || exit 1
done

if [[ "$1" == "--encode" ]]
then
    youtube-upscale-all
fi
