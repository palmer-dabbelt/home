#!/bin/bash

set -x

start_count="$(find /Volumes/scratch/Videos/rendered "/Volumes/MacOS Scratch/Videos/rendered" -name "*.mkv" -maxdepth 1 | wc -l | xargs echo)"

find /Volumes/scratch/Videos/rendered "/Volumes/MacOS Scratch/Videos/rendered" -name "*.mkv" -maxdepth 1 | sort | while read f
do
    yes | youtube-upscale --auto "$f"
done

end_count="$(find /Volumes/scratch/Videos/rendered "/Volumes/MacOS Scratch/Videos/rendered" -name "*.mkv" -maxdepth 1 | wc -l | xargs echo)"

if [[ "$start_count" != "$end_count" ]]
then
    exec $0
fi
