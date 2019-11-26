#!/bin/bash

if (( $# == 0 )); then
    echo "Usage: with-gpg COMMAND" >&2
    exit 1
fi

unset SSH_AUTH_SOCK
echo "UPDATESTATEUPTTY" | gpg-connect-agent > /dev/null
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
echo UPDATESTARTUPTTY | gpg-connect-agent > /dev/null
exec "$@"
