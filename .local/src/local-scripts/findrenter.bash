#!/bin/bash

while [[ "$(pwd)" != "/" ]]
do
    if test -d rc.d
    then
        readlink -f rc.d/riscv-tools.bashrc
        exit 0
    fi

    cd ..
done

exit 1
