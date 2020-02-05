#!/bin/bash

# Command-line argument parsing
background="true"
args="true"
window="true"
position=()
while [[ "$args" == "true" ]]
do
  case "$1" in
  --foreground)
    background="false"
    shift
    ;;
  --append)
    position=("+normal GA")
    shift
    ;;
  --fullscreen)
    window="false"
    shift
    ;;
  --*)
    echo "unknown argument $1" >&2
    exit 1
    ;;
  *)
    args="false"
    ;;
  esac
done

if [[ "$window" == "false" ]]
then
  unset DISPLAY
  unset TMUX
fi

# The actual meat of the file: opens the given list of files
if [[ "$DISPLAY" != "" ]]
then
  while [[ "$1" != "" ]]
  do
    if [[ "$background" == "true" ]]
    then
      $TERMINAL vim "${position[@]}" "$(readlink -f $1)" >& /dev/null &
    else
      $TERMINAL vim "${position[@]}" "$(readlink -f $1)" >& /dev/null
    fi
    shift
  done
elif [[ "$TMUX" != "" ]]
then
  while [[ "$1" != "" ]]
  do
    tmux split-window -h "exec vim "${position[@]}" $(readlink -f $1)"
  shift
  done
else
  while [[ "$1" != "" ]]
  do
    vim "$1"
    shift
  done
fi

# Check to see if we should be joining the files
if [[ "$background" == "false" ]]
then
  wait
fi
