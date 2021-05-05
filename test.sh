#!/bin/bash
# ./run.sh Flow210505.1 _pnfs 365678 PC 3
input="~/getflow/$3_$4_root$2.txt"
#cat ~/getflow/$3_$4_root$2.txt
linenumber=0
while IFS= read -r line; do
	if [ $5 -eq $linenumber ]; then
	    echo test
	fi
done <"$input"