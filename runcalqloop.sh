#!/bin/bash
#input="/atlasgpfs01/usatlas/data/cher97/mc16_5TeV.txt"
#input="mc16_5TeV_short.txt"
mkdir -p '/usatlas/scratch/cher97/'$1$2_$3_$4_calq
ls /pnfs/usatlas.bnl.gov/users/cher97/$1$2_$3_$4/*.root > ~/getflow/$1$2_$3_$4_rootlist.txt
input=~/getflow/$1$2_$3_$4_rootlist.txt
#cd ~/calq

#indexline=$1
linenumber=0
while IFS= read -r line; do
	if [ $1 -eq $linenumber ]; then
		tempdir=`mktemp -d`
		cd $tempdir
		echo $tempdir
		mkdir $tempdir/'tempin'$3_$4$linenumber
		xrdcp 'root://dcgftp.usatlas.bnl.gov:1096/'$line $tempdir/'tempin'$3_$4$linenumber		
		cd $tempdir/'tempin'$3_$4$linenumber
		filename=$(ls *.root*)
		mkdir $tempdir/'tempout'$3_$4$linenumber
		cd ~/calq
		root -b -q -l 'calq.C("'$filename'","'$tempdir/'tempout'$3_$4$linenumber'")'
		mv $tempdir/'tempout'$3_$4$linenumber'/*.root' '/usatlas/scratch/cher97/'$1$2_$3_$4'_calq/tempin'$3_$4_$linenumber'_calq.root'
		sleep 2
		rm -rf $tempdir
	fi
	linenumber=$((linenumber + 1))
done <$input
