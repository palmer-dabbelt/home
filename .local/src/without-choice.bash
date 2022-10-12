#!/bin/bash

git config -l | grep -e '^url[.].*[.]insteadof=.*$' | while read sub
do
    from="$(echo "$sub" | sed 's/^url[.]\(.*\)[.]insteadof=\(.*\)$/\1/')"
    to="$(echo "$sub" | sed 's/^url[.]\(.*\)[.]insteadof=\(.*\)$/\2/')"
    sed "s!${from}!${to}!" -i $1
done
