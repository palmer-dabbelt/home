#!/bin/bash

dcode="$(date +%Y-%m-%d)"
dcs="$(date +%s)"
unmount="true"

while [[ "$1" != "" ]]
do
    case "$1" in
    "--no-unmount") unmount="false"; shift 1;;
    *) exit 1;;
    esac
done

volumes=()

for volume in $(find /Volumes -name "A*" -maxdepth 1)
do
    if test -d "$volume"
    then
        volumes+=("$volume")
    fi
done

for volume in "/Volumes/Untitled" "/Volumes/M4_SD" "/Volumes/F6_SD"
do
    if test -d "$volume"
    then
        volumes+=("$volume")
    fi
done

echo "Volumes: ${volumes[@]}"

for volume in "${volumes[@]}"
do
    echo "Searching $volume"

    # Move stuff over from my camcorder
    find $volume -name "*.MXF" -or -name "*.mxf" | while read mxf
    do
        date="$(ffprobe "$mxf" 2>&1 | grep modification_date | cut -d: -f2- | sort | uniq | xargs echo)"
        ymd="$(date -j -u -z "America/Los_Angeles" -f "%Y-%m-%dT%H:%M:%S.000000Z" "$date" +"%Y-%m-%d")"
        hms="$(date -j -u -z "America/Los_Angeles" -f "%Y-%m-%dT%H:%M:%S.000000Z" "$date" +"%Y-%m-%d-%H-%M-%S")"
        xml="$(echo "$mxf" | sed "s/.MXF/M01.XML/g" | sed "s/.mxf/M01.xml/g")"
        model="$(cat "$xml" | grep "<Device" | sed 's/.*modelName="\([A-Z0-9-]*\)".*/\1/')"
        folder="/Volumes/scratch/Videos/${dcode}-${dcs}-${model}"
        mkdir -p "$folder"
        echo "Copying \"$mxf\" to \"$folder\""
        cp "$mxf" "$folder"
        cp "$xml" "$folder"
    done
    
    find $volume -name "*.MP4" | while read mp4
    do
        date="$(ffprobe "$mp4" 2>&1 | grep creation_time | cut -d: -f2- | sort | uniq | xargs echo)"
        ymd="$(date -j -u -z "America/Los_Angeles" -f "%Y-%m-%dT%H:%M:%S.000000Z" "$date" +"%Y-%m-%d")"
        hms="$(date -j -u -z "America/Los_Angeles" -f "%Y-%m-%dT%H:%M:%S.000000Z" "$date" +"%Y-%m-%d-%H-%M-%S")"
        xml="$(echo "$mp4" | sed "s/.MP4/M01.XML/g")"
        model="$(cat "$xml" | grep "<Device" | sed 's/.*modelName="\([A-Z0-9-]*\)".*/\1/')"
        folder="/Volumes/scratch/Videos/${dcode}-${dcs}-${model}"
        mkdir -p "$folder"
        echo "Copying \"$mp4\" to \"$folder\""
        cp "$mp4" "$folder"
        cp "$xml" "$folder"
    done
    
    find $volume -name "*.TAKE" | while read dir
    do
        wav="$(find "$dir" -name "*.WAV" | head -n1)"
        ymd="$(ffprobe "$wav" | grep date | cut -d: -f2- | sort | uniq | xargs echo)"
        hms="$(ffprobe "$wav" | grep creation_time | cut -d: -f2- | sort | uniq | xargs echo | sed 's/:/-/g')"
        model="Zoom"
        folder="/Volumes/scratch/Videos/${dcode}-${dcs}-${model}"
        mkdir -p "$folder"
        find "$dir" -name "*.WAV" | while read f
        do
          cp -a "$f" "$folder"
        done
    done
     
    if [[ "$unmount" == "true" ]]
    then
        diskutil unmount $volume
    fi
done

echo "Downloads..."

find -L $HOME/Downloads -name "PXL_*.mp4" | while read mp4
do
    date="$(ffprobe "$mp4" 2>&1 | grep creation_time | cut -d: -f2- | sort | uniq | xargs echo)"
    ymd="$(date -j -u -z "America/Los_Angeles" -f "%Y-%m-%dT%H:%M:%S.000000Z" "$date" +"%Y-%m-%d")"
    hms="$(date -j -u -z "America/Los_Angeles" -f "%Y-%m-%dT%H:%M:%S.000000Z" "$date" +"%Y-%m-%d-%H-%M-%S")"
    model="Pixel"
    folder="/Volumes/scratch/Videos/${dcode}-${dcs}-${model}"
    mkdir -p "$folder"
    echo "Copying \"$mp4\" to \"$folder\""
    mv "$mp4" "$folder"
done
