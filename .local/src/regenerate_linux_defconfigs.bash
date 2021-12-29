#!/bin/bash

find arch/riscv/configs -name "*defconfig" | while read f
do
    make.riscv $(basename $f)
    make.riscv savedefconfig
    mv defconfig $f
done
