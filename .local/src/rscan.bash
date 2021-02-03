#!/bin/bash

unset N
if [[ "$1" == "-N" ]]
then
    N="-N $2"
    shift 2
fi

if [[ "$1" == "" ]]
then
    exec "$0" $N riscv
fi

exec watch --no-title --color hscan $N "${@}"
