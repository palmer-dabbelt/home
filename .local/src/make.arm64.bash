#!/bin/bash

exec make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- "$@"
