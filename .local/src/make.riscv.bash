#!/bin/bash

exec make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- "$@"
