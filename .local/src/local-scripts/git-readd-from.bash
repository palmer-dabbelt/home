#!/bin/bash

git show "$@" --stat=3000 | grep '|' | cut -d'|' -f1 | while read file
do
  git add -f "$file"
done

git commit -m "git-readd-from: $(git show "$@" --oneline | head -n1)"
