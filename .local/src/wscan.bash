#!/bin/bash

if [[ "$1" == "" ]]
then
    exec "$0" inbox
fi

exec watch --no-title --color hscan "${@}"
