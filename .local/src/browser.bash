#!/bin/bash

user="palmer@dabelt.com"
window=""
while [[ "$1" != "" ]]
do
    case "$1"
    in
    --user)    user="$2";               shift 2         ;;
    --window)  window="--new-window";   shift 1;        ;;
    --)                                 shift 1;  break ;;
    --*) echo "Unknown argument $1";    exit 1;;
    *)                                  break ;;
    esac
done

profile_directory="Default"
case "$user"
in
    "palmer@dabbelt.com")   profile_directory="Profile 3"   ;;
    "palmerdabbelt@meta.com")  profile_directory="Default" ;;
esac

exec "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --profile-directory="$profile_directory" $window "$@"
