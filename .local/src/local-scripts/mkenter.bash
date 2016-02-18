#!/bin/bash

cat > enter.bash <<EOF
export RISCV="$(pwd)/install"
export PATH="\$RISCV/bin:\$PATH"
EOF
