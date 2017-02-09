#!/bin/bash

git_config="$(GIT_EDITOR=echo git config -e)"

echo "Fixing https submodule pointers in $git_config"
sed 's!https://[a-z.]/!git@github.com:!g' -i $git_config
sed 's!git://[a-z.]/!git@github.com:!g' -i $git_config
