#!/bin/bash

parallel="$(echo -- -j1 $MAKEOPTS $@ | sed 's/ /\n/g' | grep '^-j' | tail -n1 | cut -dj -f2)"

srun -c $parallel make "$@"
