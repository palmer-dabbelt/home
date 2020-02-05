#!/bin/bash

while true
do
    mtime="$(date -r /var/run/credentials-cache/loas-$(whoami)/cookies/$(whoami).loas2credentials +%s)"
    etime="$(($mtime + (18 * 60 * 60)))"
    ntime="$(date +%s)"
    dtime="$(($etime - $ntime))"
    if [[ "$dtime" -gt "0" ]]
    then
        echo "Sleeping for $dtime seconds (hopefully until $(date -d @$etime))"
        abssleep $dtime
        echo "Woke up at $(date)"
    fi
    kitty wait-for-gcert
done
