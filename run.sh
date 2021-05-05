#!/bin/bash
#input="/atlasgpfs01/usatlas/data/cher97/mc16_5TeV.txt"
# ./run.sh Flow210504.1 _pnfs 365678 PC 3

input="../getflow/$3_$4_root$2.txt"
#input="mc16_5TeV_short.txt"

mkdir -p /usatlas/scratch/cher97/$1$2_$3_$4_$5

cd ~/Flow

#indexline=$1
linenumber=0
while IFS= read -r line; do
	if [ $1 -eq $linenumber ]; then
		mkdir -p '/usatlas/scratch/cher97/tempin'$linenumber
		xrdcp 'root://dcgftp.usatlas.bnl.gov:1096/'$line '/usatlas/scratch/cher97/tempin'$linenumber		
		filename=/usatlas/scratch/cher97/tempin$linenumber/$(ls /usatlas/scratch/cher97/tempin$linenumber)
		
		sleep 2
		rm -rf '/usatlas/scratch/cher97/tempin'$linenumber
	fi
	linenumber=$((linenumber + 1))
done <"$input"

