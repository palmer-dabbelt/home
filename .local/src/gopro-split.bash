#!/bin/bash

set -x

for f in "$@"
do
    ffprobe "$f" -loglevel error -show_chapters -print_format json | jq -r '.chapters | .[] | .start_time' | while read mark_float
    do
        mark_int="$(echo "$mark_float" | cut -d. -f1)"
	ss="$(echo $(($mark_int - 20)))"
        echo "" | ffmpeg -loglevel error -i "$f" -c:a copy -c:v copy -ss "$ss" -t 30 "$f"-"$mark_int"-30.mp4
	ss="$(echo $(($mark_int - 10)))"
        echo "" | ffmpeg -loglevel error -i "$f" -c:a copy -c:v copy -ss "$ss" -t 15 "$f"-"$mark_int"-15.mp4
	ss="$(echo $(($mark_int - 5)))"
        echo "" | ffmpeg -loglevel error -i "$f" -c:a copy -c:v copy -ss "$ss" -t 5 "$f"-"$mark_int"-5.mp4
    done
done
