#!/bin/bash

auto="false"
if [[ "$1" == "--auto" ]]
then
    auto="true"
    shift
fi

for i in "$@"
do
    rendered="$(dirname "$i")/$(basename "$i" .mxf)-rendered.mov"
    if test -f "$rendered"
    then
        i="$rendered"
    fi

    out="$(dirname "$i")/8k/$(basename "$i" .mkv)".mkv
    out_8k="$out"
    if test ! -f "$out"
    then
        mkdir -p "$(dirname "$out")"
	set -x
	lut="$(find "$(dirname "$i")" -name "$(basename $(basename "$i" .mp4) .mxf)*.cube")"
	if test -f "$lut"
	then
            (
                set -x
		cd "$(dirname "$i")"
                nice -n19 ffmpeg -i "$i" -c:a flac -c:v libx264 -crf 22 -preset superfast -vf scale=-1:4320,lut3d="${lut}" -filter_complex amix -colorspace bt709 -color_primaries bt709 -color_trc bt709 -pix_fmt yuv422p "$out"
            )
	elif test -z ${i##*.mxf}
	then
            (
                set -x
                nice -n19 ffmpeg -i "$i" -c:a flac -c:v libx264 -crf 22 -preset superfast -vf scale=-1:4320 -filter_complex amix "$out"
            )
	elif test -z ${i##*.mkv}
	then
            (
                set -x
                nice -n19 ffmpeg -i "$i" -c:a flac -c:v libx264 -crf 22 -preset superfast -vf scale=-1:4320 -colorspace bt709 -color_primaries bt709 -color_trc bt709 -pix_fmt yuv422p "$out"

            )
	else
            (
                set -x
                nice -n19 ffmpeg -i "$i" -c:a flac -c:v libx264 -crf 22 -preset superfast -vf scale=-1:4320 "$out"
            )
	fi
    fi

    out="$(dirname "$i")/4k/$(basename "$i" .mkv)".mkv
    out_4k="$out"
    if test ! -f "$out"
    then
        mkdir -p "$(dirname "$out")"
	set -x
	lut="$(find "$(dirname "$i")" -name "$(basename $(basename "$i" .mp4) .mxf)*.cube")"
	if test -f "$lut"
	then
            (
                set -x
		cd "$(dirname "$i")"
                nice -n19 ffmpeg -i "$i" -c:a libopus -c:v libx265 -colorspace bt709 -color_primaries bt709 -color_trc bt709 -pix_fmt yuv422p10le -preset medium -crf 24 -map 0:v -map 0:a -vf lut3d="${lut}" "$out"
            )
	elif test -f "$rendered"
	then
            (
                set -x
		cd "$(dirname "$i")"
                nice -n19 ffmpeg -i "$i" -c:a libopus -c:v libx265 -colorspace bt709 -color_primaries bt709 -color_trc bt709 -pix_fmt yuv422p10le -preset medium -crf 24 -map 0:v -map 0:a "$out"
            )
	elif test -z ${i##*.mxf}
	then
            (
                set -x
                nice -n19 ffmpeg -i "$i" -c:a libopus -c:v libsvtav1 -crf 18 -preset 4 -g 300 -tiles 2x2 -map 0:v -map 0:a "$out"
            )
	elif test -z ${i##*.mkv}
	then
            (
                set -x
                nice -n19 ffmpeg -i "$i" -c:a libopus -c:v libx265 -colorspace bt709 -color_primaries bt709 -color_trc bt709 -pix_fmt yuv422p10le -preset medium -crf 24 -map 0:v -map 0:a "$out"
            )
	else
            (
                set -x
                nice -n19 ffmpeg -i "$i" -c:a libopus -c:v libsvtav1 -crf 18 -preset 4 -g 300 -tiles 2x2 "$out"
            )
	fi
    fi

    if [[ "$auto" == "true" ]]
    then
	cp -a "$out_4k" /Volumes/archive/Videos/Family/ || exit 1
	youtubeuploader -filename "$out_8k" || exit 1
        rm "$i" "$out_4k" "$out_8k"
    fi
done
