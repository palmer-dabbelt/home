#!/bin/bash

cat > enter.bash <<EOF
export RISCV="$(pwd)/install"
export PATH="\$RISCV/bin:\$PATH"

if test -f /ecad/tools/vlsi.bashrc
then
  source /ecad/tools/vlsi.bashrc
fi
EOF
