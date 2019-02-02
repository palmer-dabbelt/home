#!/bin/bash

set -ex

unset branch_name
unset remote
original_branch="$(git rev-parse --abbrev-ref HEAD)"

while [[ "$1" != "" ]]
do
    case "$1"
    in
    "--branch-name") branch_name="$2"; shift 2;;
    "--branch")      branch_name="$2"; shift 2;;
    "--remote")      remote="$2";      shift 2;;
    *) echo "$0: unknown argument $1">&2; exit 1;;
    esac
done

if [[ "$branch_name" == "" || "$remote" == "" ]]
then
    echo "$0: needs --branch-name and --remote"
    exit 1
fi

git checkout $remote/$branch_name -b $branch_name
git rm -rf .
git commit -m "delete for archive"
git checkout $remote/__archive__ -b __archive__
git merge $branch_name || (
	git add README*
	git commit
)
git push $remote __archive__
git branch -D $branch_name
git push $remote :$branch_name
git checkout "$original_branch"
git branch -d __archive__
