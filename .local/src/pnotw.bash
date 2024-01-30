#!/bin/bash

repo="$HOME/work/rivos-notes/"

headersext="headers"
prefix=""
if [[ "$1" == "--draft" ]]
then
    headersext="draft-headers"
    prefix="[DRAFT] "
    shift
fi

project="$1"
if [[ "$1" == "" ]]
then
    echo "no project provided"
    exit 1
fi

case "$project"
in
    t*)     project="toolchain" ;;
    k*)     project="kernel" ;;
    b*)     project="boss" ;;
    d*)     project="distro" ;;
    *) echo "unknown project $project"; exit 1;;
esac

date=""
case "$project"
in
    toolchain)    date="@$(date +%s -d "9am this thursday")" ;;
    kernel)       date="@$(date +%s -d "9am this thursday")" ;;
    boss)         date="@$(date +%s -d "9am this friday")" ;;
    distro)       date="@$(date +%s -d "8am this thursday")" ;;
    *)            date="@$(date +%s)" ;;
esac

if [[ "$project" == "boss" ]]
then
    repo="$HOME/work/palmer-notes/"
fi

file="$repo"/"$project"-"$(date +%Y-%m-%d -d "$date")".md
headers="$repo"/"$project"."$headersext"

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

if [[ "$headersext" == "draft-headers" ]]
then
    echo "[Edit Link on Rivos Gitlab](https://gitlab.ba.rivosinc.com/rv/sandbox/palmer/rivos-notes/-/edit/master/$project-$(date +%Y-%m-%d -d "$date").md)" > "$tmp"/notesfile.md
    echo "" >> "$tmp"/notesfile.md
    cat "$file" >> "$tmp"/notesfile.md
    file="$tmp"/notesfile.md
fi

#pandoc -o "$tmp"/notes.pdf "$file" -V geometry:margin=1cm
#pandoc -o "$tmp"/notes.html "$file"
markdown_py <"$file" >"$tmp"/notes.html

#zathura "$tmp"/notes.pdf >& /dev/null
(
	$BROWSER --user palmer@rivosin.com "$tmp"/notes.html
	sleep 5s
) &

cat "$headers" > "$tmp"/message
cat "$file" | grep ^# | head -n1 | sed "s/^# /Subject: $prefix/" >> "$tmp"/message
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

wait
