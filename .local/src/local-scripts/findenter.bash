#!/bin/bash

while [[ "$(pwd)" != "/" ]]
do
    if test -f enter.bash
    then
        readlink -f enter.bash
        exit 0
    fi

    cd ..
done

exit 1
