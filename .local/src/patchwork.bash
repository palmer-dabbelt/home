#!/bin/bash

case "$1" in
l*)     exec browser --user palmer@dabbelt.com "https://patchwork.kernel.org/project/linux-riscv/list/" ;;
glibc)  exec browser --user palmer@dabbelt.com "https://patchwork.sourceware.org/project/glibc/list/" ;;
gcc)    exec browser --user palmer@dabbelt.com "https://patchwork.sourceware.org/project/gcc/list/?q=risc-v" ;;
esac
