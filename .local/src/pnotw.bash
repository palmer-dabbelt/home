#!/bin/bash

repo="$HOME/work/notes/"

project=boss
datestr="now"
if [[ "$1" != "" ]]
then
    project="$1"
fi
if [[ "$2" != "" ]]
then
    datestr="$2"
fi

file="$repo"/"$project"-"$(date +%Y-%m-%d -d"$datestr")".md
headers="$repo"/"$project".headers

if [[ "$(nmcli g | grep ^connected | wc -l)" == "1" ]]
then
    git -C "$repo" pull --rebase
fi

if ! test -f "$file"
then
    echo "No notes $file"
    exit 1
fi

tmp="$(mktemp -d)"
trap "rm -rf $tmp" EXIT

pandoc -o "$tmp"/notes.pdf "$file" -V geometry:margin=1cm
pandoc -o "$tmp"/notes.html "$file"

zathura "$tmp"/notes.pdf >& /dev/null

cat "$headers" > "$tmp"/message
cat "$file" | grep ^# | head -n1 | sed 's/^# /Subject: /' >> "$tmp"/message
cat >> "$tmp"/message <<EOF
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary=notw

EOF
cat >> "$tmp"/message <<EOF
--notw
Content-type: text/plain
Content-transfer-encoding: base64

EOF
cat "$file" | base64 >> "$tmp"/message
cat >> "$tmp"/message <<EOF
--notw
Content-type: text/html
Content-transfer-encoding: base64

EOF
cat "$tmp"/notes.html | base64 >> "$tmp"/message
cat >> "$tmp"/message <<EOF
--notw--
EOF

cat "$tmp"/message | mhng-pipe-comp_stdin
#lp "$tmp"/notes.pdf

if ! test -f "$repo"/"$project".children
then
    echo "Unknown project children: $repo/$project.children"
    exit 1
fi
children="$repo"/"$project".children

cat "$children" | while read c
do
   $0 $c
done
