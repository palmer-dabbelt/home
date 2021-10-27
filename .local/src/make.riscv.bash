#!/bin/bash

exec nice -n10 make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- "$@"
