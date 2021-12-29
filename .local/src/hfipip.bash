#!/bin/bash

if test -d $HOME/.mhng
then
    $HOME/.local/bin/mhng-hfipip riscv | ssh palmer_dabbelt@ssh.phx.nearlyfreespeech.net "cat > ~palmer/hfipip.html"
fi
