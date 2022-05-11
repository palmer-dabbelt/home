#!/bin/bash

echo "https://lore.kernel.org/r/$(mhng-pipe-header message-id "$@" | sed 's/<\(.*\)>/\1/' | sed 's/\+/%2B/g' | sed 's@/@%2F@g')"
