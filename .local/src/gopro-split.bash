#!/bin/bash

set -x

for f in "$@"
do
    ffprobe "$f" -loglevel error -show_chapters -print_format json | jq -r '.chapters | .[] | .start_time' | cut -d. -f1 | while read mark_int
    do
        printf -v mark_pad "%05d" $mark_int

	seek="$(($mark_int - 90))"
	yes | ffmpeg -loglevel error -i "$f" -c:a copy -c:v copy -ss $seek -t 180 "$f"-$mark_pad.mp4
    done
done
