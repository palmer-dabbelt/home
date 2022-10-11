#!/bin/bash

unset N
if [[ "$1" == "-N" ]]
then
    N="-N $2"
    shift 2
fi

if [[ "$1" == "--fixes" ]]
then
   G="--grep fix"
   shift 1
fi

if [[ "$1" == "" ]]
then
    exec "$0" $N $G riscv
fi

exec watch --no-title --color hscan $N $G "${@}"
