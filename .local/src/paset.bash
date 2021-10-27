#!/bin/bash

snkname="$(pacmd list-sinks | grep "name: .*$1.*" | grep -v ".monitor" | sed 's@ *name: <\([A-Za-z0-9_.-]*\)>.*@\1@' | xargs echo)"
srcname="$(pacmd list-sources | grep "name: .*$1.*" | grep -v ".monitor" | sed 's@ *name: <\([A-Za-z0-9_.-]*\)>.*@\1@' | xargs echo)"

pacmd << EOF
set-default-source $srcname
set-default-sink $snkname
EOF

pactl list sink-inputs short | cut -f1 | while read index
do
    pacmd move-sink-input "$index" "$snkname"
done

pactl list source-outputs short | grep -v "25Hz" | cut -f1 | while read index
do
    pacmd move-source-output "$index" "$srcname"
done
