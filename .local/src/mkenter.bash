#!/bin/bash

cat > enter.bash <<EOF
export PKG_CONFIG_PATH="$HOME/.local/lib/pkgconfig:$PKG_CONFIG_PATH"
EOF
