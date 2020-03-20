#!/bin/bash

whoami="Palmer Dabbelt <palmerdabbelt@google.com>";

echo "$@" | sed 's/\(.\)/\1\n/g' | while read c
do
    case "$c"
    in
        a) echo "Acked-by: $whoami";;
        r) echo "Reviewed-by: $whoami";;
        s) echo "Signed-off-by: $whoami";;
        t) echo "Tested-by: $whoami";;
        "");;
        " ");;
        *)
            echo "Unknown argument '$c'" >&2
            exit 1
            ;;
    esac
done
