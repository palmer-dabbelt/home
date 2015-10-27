#!/bin/bash

# This is a login shell
source $HOME/.bash_profile

# There's a bunch of directories that I want to always have 
mkdir -p ~/.local/log/mbacklight/
mkdir -p ~/.local/log/mhng-daemon/
mkdir -p ~/.local/log/mhng-notify/

# The window manager needs to run first, and I pretty much always want
# to run this window manager.
/usr/bin/awesome &

#########################################################
# Display Configuration
#########################################################
if [[ "$HOSTNAME" == "palmer-mbp2014" ]]
then
    xrandr --dpi 157

    ( while true
      do
          mbacklight &>> ~/.local/log/mbacklight/$HOSTNAME.log
	  sleep 5m
      done ) &
fi

if [[ "$HOSTNAME" == "palmer-x220" ]]
then
    xbacklight -set 70
    xrandr --dpi 125
fi

if test -f /etc/acpi/actions/xrandr.sh
then
    xhost +localhost
    xhost +local:
    /etc/acpi/actions/xrandr.sh &
fi

if test -f ~/.local/etc/redshift/$HOSTNAME.conf
then
    ( while true
      do
          redshift -c ~/.local/etc/redshift/$HOSTNAME.conf &>> ~/.local/log/redshift/$HOSTNAME.log
          sleep 1s
      done ) &
fi

#########################################################
# Notification Daemons
#########################################################
if test -f /usr/bin/nm-applet
then
    ( while true
      do
          /usr/bin/nm-applet
          sleep 1s
      done ) &
fi

if test -f /usr/bin/cbatticon &
then
    ( while true
      do
          /usr/bin/cbatticon
          sleep 1s
      done ) &
fi

if test -f ~/.mhng/username
then
    ( while true
      do
          mhng-daemon &>> ~/.local/log/mhng-daemon/$HOSTNAME.log
          sleep 1s
      done ) &

    ( sleep 5s
      while true
      do
          mhng-notify &>> ~/.local/log/mhng-notify/$HOSTNAME.log
          sleep 1s
      done ) &
fi

#########################################################
# Synergy
#########################################################
if test -f ~/.local/etc/synergys/$HOSTNAME.conf
then
    ( while true
      do
          synergys -f -c ~/.local/etc/synergys/$HOSTNAME.conf &>> ~/.local/log/synergys/$HOSTNAME.log
          sleep 1s
      done ) &
fi

if test -f ~/.local/etc/synergyc/$HOSTNAME.conf
then
    ( while true
      do
          synergyc -f $(cat ~/.local/etc/synergyc/$HOSTNAME.conf) &>> ~/.local/log/synergyc/$HOSTNAME.log
          sleep 1s
      done ) &
fi

#########################################################
# Applications
#########################################################
# My home Lulu laptop wants Firefox to run so I can talk to Lulu on
# the phone
if [[ "$HOSTNAME" == "palmer-x220" ]]
then
    firefox &
fi

# My work Lulu laptop wants hexchat to run so I can talk to Lulu over
# IM
if [[ "$HOSTNAME" == "palmer-cb1101" ]]
then
    hexchat &
fi

#########################################################
# Job Control                                           #
#########################################################
wait
