#!/bin/bash
#input="/atlasgpfs01/usatlas/data/cher97/mc16_5TeV.txt"
# ./run.sh Flow210504.1 _pnfs 365678 PC 3

input=~/getflow/$1$2_$3_$4_rerun.txt
#input="mc16_5TeV_short.txt"
mkdir -p '/usatlas/scratch/cher97/'$1$2_$3_$4

#indexline=$1
linenumber=0
while IFS= read -r line; do
	if [ $5 -eq $linenumber ]; then
		bash ~/getflow/runloop.sh $1 $2 $3 $4 $(($line))
	fi
	linenumber=$((linenumber + 1))
done <$input