#!/bin/sh
echo $1
zathura -s -x "gvim --servername $1 -c \"let g:syncpdf='$1'\" --remote +%{line} %{input}" $*
