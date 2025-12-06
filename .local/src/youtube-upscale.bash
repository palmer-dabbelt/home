#!/bin/bash

for i in "$@"
do
    out="$(dirname "$i")/8k/$(basename "$i")"
    if test ! -f "$out".mkv
    then
        mkdir -p "$(dirname "$out")"
	set -x
	lut="$(find "$(dirname "$i")" -name "$(basename $(basename "$i" .mp4) .mxf)*.cube")"
	if test -f "$lut"
	then
            (
                set -x
		cd "$(dirname "$i")"
                nice -n19 ffmpeg -i "$i" -c:a flac -c:v libx264 -crf 22 -preset superfast -vf scale=7680:-1,lut3d="${lut}" -filter_complex amix -colorspace bt709 -color_primaries bt709 -color_trc bt709 -pix_fmt yuv422p "$out".mkv
                #nice -n19 ffmpeg -i "$i" -c:a copy -c:v libx265 -crf 18 -preset superfast -vf scale=7680:-1,lut3d="${lut}" -colorspace bt2020nc -color_primaries bt2020 -color_trc bt2020-10 -pix_fmt yuv422p10 "$out".mkv
                #nice -n19 ffmpeg -i "$i" -c:a copy -c:v libx265 -crf 18 -preset superfast -vf scale=7680:-1,lut3d="${lut}" "$out".mkv
            )
	elif test -z ${i##*.mxf}
	then
            (
                set -x
                nice -n19 ffmpeg -i "$i" -c:a flac -c:v libx264 -crf 22 -preset superfast -vf scale=7680:-1 -filter_complex amix "$out".mkv
            )
	else
            (
                set -x
                nice -n19 ffmpeg -i "$i" -c:a flac -c:v libx264 -crf 22 -preset superfast -vf scale=7680:-1 "$out".mkv
            )
	fi
    fi
    youtubeuploader -filename "$f"
done
