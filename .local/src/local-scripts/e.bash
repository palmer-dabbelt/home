#!/bin/bash

set -x

# Command-line argument parsing
background="true"
args="true"
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
  --*)
    echo "unknown argument $1" >&2
    exit 1
    ;;
  *)
    args="false"
    ;;
  esac
done

# The actual meat of the file: opens the given list of files
if [[ "$DISPLAY" != "" ]]
then
  while [[ "$1" != "" ]]
  do
    urxvt -e vim "${position[@]}" "$(readlink -f $1)" &
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
  vim "$@"
fi

# Check to see if we should be joining the files
if [[ "$background" == "false" ]]
then
  wait
fi
