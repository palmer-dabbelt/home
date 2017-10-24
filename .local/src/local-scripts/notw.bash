#!/bin/sh

FOLDER="$HOME/work/palmer-notes"

date="now"
while [[ "$1" != "" ]]
do
  case "$1" in
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
  cat >$note <<EOF
# Weekly Notes for $(date -d "$date" "+%A %B %e, %Y")
EOF
else
  echo "# FIXME: Additional Edits!" >> $note
fi

for x in $(seq 0 14)
do
  if [[ "$x" -gt 0 ]]
  then
    weeknote=week-"$(date -d "$date $x days ago" "+%Y-%m-%d")".md
    if test -f "$weeknote"
    then
      break
    fi
  fi

  daynote=day-"$(date -d "$date $x days ago" "+%Y-%m-%d")".md
  if test -f "$daynote"
  then
    cat "$daynote" | sed 's/^#/##/g' >> "$note"
  fi
done

e --append --foreground "$note"

git add .
git commit -m "automatic commit from $0"
git push
