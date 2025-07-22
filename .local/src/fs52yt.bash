#!/bin/bash

in="$1"
out="$2"
if [[ "$out" == "" ]]
then
    out="$in".mp4
fi

ffmpeg -i "$in" -c:v copy -c:a flac -map 0:v:0 -map 0:a:1 -map 0:a:0 "$out"
