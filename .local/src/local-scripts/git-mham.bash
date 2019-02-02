#!/bin/bash

mhng-pipe-scan "$@" | sort -k 4 | cut -d' ' -f1 | while read seqnum
do
    mhng-pipe-show_stdout "$seqnum" | git am -3sS
done
