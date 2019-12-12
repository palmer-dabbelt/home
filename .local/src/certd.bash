#!/bin/bash

while true
do
    mtime="$(date -r /var/run/credentials-cache/loas-$(whoami)/cookies/$(whoami).loas2credentials +%s)"
    etime="$(($mtime + (18 * 60 * 60)))"
    ntime="$(date +%s)"
    dtime="$(($etime - $ntime))"
    echo "Sleeping for $dtime seconds (hopefully until $(date -d @$etime))"
    sleep $dtime
    kitty wait-for-gcert
done
