#!/bin/bash
#input="/atlasgpfs01/usatlas/data/cher97/mc16_5TeV.txt"
# ./runrootloop.sh no1 process no2 executable no3 inputname no4 outputfolder

input=~/getflow/txts/$3.txt
#input="mc16_5TeV_short.txt"
mkdir -p $4

#indexline=$1
linenumber=0
while IFS= read -r line; do
	if [ $1 -eq $linenumber ]; then
		echo $line
		tempdir=$(mktemp -d)
		cd $tempdir
		echo $tempdir
		mkdir -p $tempdir/'tempin'$linenumber
		xrdcp 'root://dcgftp.usatlas.bnl.gov:1096/'$line $tempdir/'tempin'$linenumber
		cd $tempdir/'tempin'$linenumber
		filename=$(ls *.root*)
		echo $filename
		file=${filename%%.root*}
		root -q -b -l "$2"'("'$filename'","'$4'/'$file'_out.root","'$4'/'$file'_counts.csv")'
		sleep 2
		rm -rf $tempdir/tempin$linenumber
		rm -rf $tempdir
	fi
	linenumber=$((linenumber + 1))
done <$input
