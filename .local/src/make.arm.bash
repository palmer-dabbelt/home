#!/bin/bash

exec make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- "$@"
