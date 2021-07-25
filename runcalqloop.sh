#!/bin/bash
# ./runcalqloop.sh Flow210504.1 _pnfs 365678 PC 43 Calq210510.1 2
#mkdir -p /usatlas/scratch/cher97/$1$2_$3_$4_calq_$6_v$7
input=~/getflow/$1$2_$3_$4_rootlist.txt
#cat ~/getflow/$1$2_$3_$4_rootlist.txt

#cd ~/calq

#indexline=$1
linenumber=-2
while IFS= read -r line; do
	if [ $5 -eq $linenumber ]; then
		tempdir=`mktemp -d`
		cd $tempdir
		echo $tempdir
		mkdir $tempdir/'tempin'$3_$4$linenumber
		xrdcp $line $tempdir/'tempin'$3_$4$linenumber		
		cd $tempdir/'tempin'$3_$4$linenumber
		filename=$(ls *.root*)
		mkdir $tempdir/'tempout'$3_$4$linenumber
		cd ~/calq
		root -b -q -l 'calq.C("'$tempdir/tempin$3_$4$linenumber/$filename'","'$tempdir/'tempout'$3_$4$linenumber'",'$7')'
		#xrdcp $tempdir/tempout$3_$4$linenumber/*.root root://dcgftp.usatlas.bnl.gov:1096//pnfs/usatlas.bnl.gov/users/cher97/$1$2_$3_$4_calq_$6_v$7/${filename%%.*}_calq.root
cp $tempdir/tempout$3_$4$linenumber/*.root /atlasgpfs01/usatlas/data/cher97/$1$2_$3_$4_calq_$6_v$7/${filename%%.*}_calq.root
		echo ${filename%%.*}
		sleep 2
		rm -rf $tempdir
	fi
	linenumber=$((linenumber + 1))
done <$input
