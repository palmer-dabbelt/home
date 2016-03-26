#!/bin/bash

tempdir="$(mktemp -d /tmp/pmake.XXXXXXXX)"
trap "rm -rf $tempdir" EXIT

logfile="$(mktemp $(pwd)/.pmake-log.XXXXXXXX)"
touch $logfile

jobfile="$tempdir/pmake-$1"
export > $jobfile
cat >>$jobfile <<EOF
cd $(pwd)
make $@ >& $logfile
EOF

parallel="$(echo -- -j1 $MAKEOPTS $@ | sed 's/ /\n/g' | grep '^-j' | tail -n1 | cut -dj -f2)"

qsub -l nodes=1:ppn=$parallel $jobfile

tail -f $logfile
