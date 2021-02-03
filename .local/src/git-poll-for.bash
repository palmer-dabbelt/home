#!/bin/bash

unset reset
if [[ "$1" == "--reset" ]]
then
    reset="true"
    shift 1
fi

while [[ "$(git show "$@" |& wc -l)" < 4 ]]
do
    sleep 10s
    git fap
done

if [[ "$reset" == "true" ]]
then
    git reset --hard "$@"
fi
