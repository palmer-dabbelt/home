#!/bin/bash

if test -d $HOME/.mhng
then
    $HOME/.local/bin/mhng-hfipip | ssh palmer_dabbelt@ssh.phx.nearlyfreespeech.net "cat > ~palmer/hfipip.html"
fi

if test -f $HOME/ping-png.gnuplot
then
    gnuplot $HOME/ping-png.gnuplot | ssh palmer_dabbelt@ssh.phx.nearlyfreespeech.net "cat > ~palmer/internet.png"
fi
