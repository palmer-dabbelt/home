#!/bin/bash

deskmic="false"
speakers="false"
headset="false"
wireless="false"
stereo="false"
mute_cbll="false"
mute_cblr="false"
mute_cbrl="false"
mute_cbrr="false"
case "$1" in
    o*)      ;;
    d*)      deskmic="true";
             speakers="true";
             ;;
    h*)      headset="true";
             ;;
    w*)      wireless="true";
             ;;
    s*)      stereo="true";
             ;;
    ears)    mute_cblr="true";
	     mute_cbrl="true";
	     headset="true";
	     ;;
    *)       echo "$0: unknown flavor $1">&2;
             exit 1;;
esac

ssh -tt default@10.64.5.1 <<EOF
Mixer1 set inputMute 3 $mute_cbll
Mixer1 set inputMute 4 $mute_cblr
Mixer1 set inputMute 5 $mute_cbrl
Mixer1 set inputMute 6 $mute_cbrr
AecInput1 set phantomPower  7 $stereo
AecInput1 set phantomPower  8 $stereo
AecInput1 set phantomPower  9 $wireless
AecInput1 set phantomPower 10 $wireless
AecInput1 set phantomPower 11 $headset
AecInput1 set phantomPower 12 $deskmic
EOF
