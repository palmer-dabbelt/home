#!/bin/bash

git pull --no-ff --no-commit --allow-unrelated-histories --strategy=dont $@
git commit -m "didn't merge $@"
