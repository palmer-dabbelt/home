#!/bin/bash

set -x

find /Volumes/scratch/Videos/ -name "*.mp4" -or -name "*.mxf" | grep -v -- "8k" | sort | while read f
do
    yes | youtube-upscale "$f"
done
