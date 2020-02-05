#!/bin/bash

while true
do
    date
    hfipip
    abssleep $((45 + RANDOM % 30))
done
