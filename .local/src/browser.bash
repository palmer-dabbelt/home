#!/bin/bash

user="palmer@dabelt.com"
while [[ "$1" != "" ]]
do
    case "$1"
    in
    --user)    user="$2";     shift 2         ;;
    --)                       shift 1;  break ;;
    --*) echo "Unknown argument $1";    exit 1;;
    *)                                  break ;;
    esac
done

profile_directory="Default"
case "$user"
in
    "palmer@dabbelt.com")   profile_directory="Default"   ;;
    "palmer@rivosinc.com")  profile_directory="Profile 1" ;;
esac

exec google-chrome-stable --profile-directory="$profile_directory" "$@"
