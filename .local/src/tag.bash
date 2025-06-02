#!/bin/bash

whoami="Palmer Dabbelt <palmer@dabbelt.com>";

echo "$@" | sed 's/\(.\)/\1\n/g' | while read c
do
    case "$c"
    in
        a) echo "Acked-by: $whoami";;
        r) echo "Reviewed-by: $whoami";;
        s) echo "Signed-off-by: $whoami";;
        t) echo "Tested-by: $whoami";;
        S) echo "Cc: stable@vger.kernel.org";;
	d) echo "Signed-off-by: Palmer Dabbelt <palmer@dabbelt.com>";;
	L) echo "Link: $(make-lore-link)";;
        "");;
        " ");;
        *)
            echo "Unknown argument '$c'" >&2
            exit 1
            ;;
    esac
done
