#!/bin/bash

while read line ; do
        case "${line}" in
        Message-[iI][dD]:*)
                MSGID="${line/#*: /}"
                ;;
        *)
                ;;
        esac
done

if [ -z "${MSGID}" ] ; then
        echo Error: No message ID found
        exit 1
fi
MSGID_NOBRACES=$(echo "${MSGID}" | sed 's/<//g' | sed 's/>//g')

PID=$(pwclient search -m "${MSGID}" -p linux-arm-kernel -f '%{id}')

if [ -z "${PID}" ] ; then
        echo Error: No patch ID found for Message ID "${MSGID}"
        exit 1
fi

echo patchwork patch id: ${PID}

pwclient view "${PID}" | git am -s && \
GIT_EDITOR="git interpret-trailers --where start --trailer \"Link: https://lore.kernel.org/r/${MSGID_NOBRACES}\" --in-place" git commit --amend && \
pwclient update -s Queued -c "$(git log -1 --format=%H)" "${PID}"
