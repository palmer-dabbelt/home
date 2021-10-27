#!/bin/bash

case "$1"
in
    savi|poly)
        paset Savi_8200
    ;;
    
    wire|usb|head*)
        paset Speed_Dragon
    ;;
esac
