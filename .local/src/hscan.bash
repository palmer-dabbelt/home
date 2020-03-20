#!/bin/bash

exec mhng-pipe-scan_pretty "$@" | head -n$(tput lines)
