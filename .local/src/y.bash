#!/bin/bash

if (( $# == 0 )); then
    echo "Usage: with-gpg COMMAND" >&2
    exit 1
fi

export GPG_TTY="$(tty)"
unset SSH_AUTH_SOCK
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
echo UPDATESTARTUPTTY | gpg-connect-agent > /dev/null
exec "$@"
