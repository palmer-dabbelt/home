#!/bin/sh

FOLDER="$HOME/work/palmer-notes"

date="now"
from="si"
to=("drew" "yunsup" "jim" "mjc" "hisen")
copies="$(($(echo "${to[*]}" | wc -w) - 2))"
while [[ "$1" != "" ]]
do
  case "$1" in
  --copies)
    copies="$2"
    shift
    shift
    ;;
  *)
    date="$1"
    shift
    ;;
  esac
done

note=week-"$(date -d "$date" "+%Y-%m-%d")".md

cd "$FOLDER"

if test ! -f "$note"
then
  echo "Create a note for $date"
  exit 1
fi

tempdir="$(mktemp -d)"
trap "rm -rf $tempdir/output.pdf" EXIT

pandoc -V geometry:margin=2cm "$note" -o "$tempdir"/output.pdf
pandoc "$note" -o "$tempdir"/"$(date -d "$date" "+%Y-%m-%d")".html
zathura "$tempdir"/output.pdf

cat >>"$tempdir"/mail <<EOF
From: $from
To: $(echo "${to[*]}" | sed 's/ /,/g')
Subject: Software Meeting Weekly Notes for $(date -d "$date" "+%A %B %e, %Y")
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="----=__pnotw_MIME"
Message-ID: <pnotw-$(date +%s)-$(uuidgen)@$HOSTNAME>

------=__pnotw_MIME
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit

$(cat "$note")
------=__pnotw_MIME
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: base64

$(base64 "$tempdir"/"$(date -d "$date" "+%Y-%m-%d")".html)
------=__pnotw_MIME--

EOF

if [[ "$(pdfinfo "$tempdir"/output.pdf | grep Pages | awk '{print $2}')" != "1" ]]
then
  echo "More than one page"
  exit 1
fi

if [[ "$copies" != "0" ]]
then
  for x in $(seq 1 "$copies")
  do
    lpr "$tempdir"/output.pdf
  done
fi

cat "$tempdir"/mail | mhng-pipe-comp_stdin

rm -rf "$tempdir"
