#!/bin/bash
#input="/atlasgpfs01/usatlas/data/cher97/mc16_5TeV.txt"
# ./runtruthloop.sh (no1 tag):Truth220211.1 (no2 location):_pnfs (no3 dataset):15_5TeV_e4962 (no4 file number):3 (no5 etalim):2.5 (no6 truthpt):1.0 


#./runtruthloop.sh Truth220211.1 _pnfs 15_5TeV_e4962 3 2.5 1.0 

input=~/getflow/txts/$3_root$2.txt
#input="mc16_5TeV_short.txt"
mkdir -p /atlasgpfs01/usatlas/data/cher97/$1$2_$3'_EVNTTruth_'$5_$6

#indexline=$1
linenumber=0
while IFS= read -r line; do
	if [ $4 -eq $((linenumber-offset)) ]; then
		tempdir=$(mktemp -d)
		cd $tempdir
		echo $tempdir
		mkdir $tempdir/'tempin'$3_$linenumber
		xrdcp 'root://dcgftp.usatlas.bnl.gov:1096/'$line $tempdir/'tempin'$3_$linenumber
		cd $tempdir/'tempin'$3_$linenumber
		filename=$(ls *.root*)
		echo $filename
		mkdir $tempdir/'tempout'$3_$linenumber
		cd $tempdir/'tempout'$3_$linenumber
		root -q '/usatlas/u/cher97/mysel/mysel.C("'$filename'", "'$tempdir/'tempin'$3_$linenumber'", "/atlasgpfs01/usatlas/data/cher97/'$1$2_$3'_EVNTTruth_'$5_$6'", '$5', '$6')'
		#cp $tempdir/tempout$3_$linenumber/*.root /atlasgpfs01/usatlas/data/cher97/$1$2_$3'_MCEff_'$5_$6_$7_$8/
		sleep 2
		rm -rf $tempdir/tempin$3_$linenumber
		rm -rf $tempdir/tempout$3_$linenumber
		rm -rf $tempdir
	fi
	linenumber=$((linenumber + 1))
done <$input
