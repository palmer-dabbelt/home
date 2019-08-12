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

PID="$(pwclient list -m "${MSGID}" -f '%{id}')"

if [ -z "${PID}" ] ; then
        echo Error: No patch ID found for Message ID "${MSGID}"
        exit 1
fi

read -a args <<< $(pwclient view "${PID}" | sed -z 's@.*The following changes since commit \([^\n]*\):.*are available in the .it repository at:[[:space:]]*\([a-zA-Z0-9:/.-]*\)[[:space:]]*\([a-zA-Z0-9:/.-]*\).*for you to fetch changes up to \([0-9a-fA-F]*\):.*@\1 \4 \2 \3\n@')

echo "Fetching from ${args[2]} ${args[3]}"
git fetch "${args[2]}" "${args[3]}" || ( echo "Fetch failed" ; exit 1 )

top_hash="$(git log -1 --format=%H FETCH_HEAD)"
if [ "${top_hash}" != "${args[1]}" ] ; then
        echo "Topmost hash is not the same. Expected ${args[1]}"
        exit 1
fi

git merge --no-ff --log --no-edit FETCH_HEAD && \
git log -1 && \
GIT_EDITOR="git interpret-trailers --where start --trailer \"Link: https://lore.kernel.org/r/${MSGID_NOBRACES}\" --in-place" git commit --amend -s  &&
pwclient update -p linux-soc -s Queued -c "$(git log -1 --format=%H)" "${PID}"
