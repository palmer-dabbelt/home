#!/bin/bash

set -x

find /Volumes/scratch/Videos/ -name "*.mp4" -or -name "*.mxf" | sort | while read f
do
    yes | youtube-upscale "$f"
done
