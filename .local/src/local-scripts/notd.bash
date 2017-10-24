#!/bin/sh

FOLDER="$HOME/work/palmer-notes"

date="now"
human="palmer"
while [[ "$1" != "" ]]
do
  case "$1" in
  --human)
    human="$2"
    shift
    shift
    ;;
  *)
    date="$1"
    shift
    ;;
  esac
done

unset fullname
case "$human" in
palmer) fullname="Palmer Dabbelt";;
*) echo "Unknown human $human" >&2; exit 1;;
esac

note=day-"$(date -d "$date" "+%Y-%m-%d")".md

cd "$FOLDER"

if test ! -f "$note"
then
  cat >$note <<EOF
# $(date -d "$date" "+%A %B %e, %Y")
EOF
else
  echo "* " >> $note
fi

e --append --foreground "$note"

git add .
git commit -m "automatic commit from $0"
git push
