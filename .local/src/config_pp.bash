#!/bin/bash

set -e
set -o pipefail

input_files=[]
input_files_count=0

output_file=""

while [[ "$1" != "" ]]
do
	if [[ "$1" == "-o" ]]
	then
		output_file="$2"
		shift
		shift
	else
		input_files[input_files_count]="$1"
		input_files_count=$((input_files_count + 1))
		shift
	fi
done

cat ${input_files[*]} > $output_file
