seq="$(mhng-pipe-scan garmin | grep "noreply@garmin.com" | tail -n1 | cut -d' ' -f1)"
mhng-pipe-urls garmin :$seq 2
