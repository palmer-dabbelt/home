#!/bin/bash

exec nice -n10 make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- "$@"
