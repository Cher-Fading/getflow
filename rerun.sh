#!/bin/bash

#./rerun.sh Flow210505.1 365678 CC May
cd /pnfs/usatlas.bnl.gov/users/cher97/
ls -h -l $1_pnfs_$2_$3 >~/getflow/$1_pnfs_$2_$3_stat.txt

input=~/getflow/$1_pnfs_$2_$3_stat.txt
#cat ~/getflow/$1_runlist.txt

rm ~/getflow/$1_pnfs_$2_$3_rerun.txt
touch ~/getflow/$1_pnfs_$2_$3_rerun.txt

linenumber=0
while IFS= read -r line; do
	b=${line#*'usatlas '}
#	echo $b
	c=${b%%' '$4*}
	d=${b##*'_'}
	e=${d%%'.root'*}
#	echo $c
	if [ $c == 0 ]; then
		echo $e
		echo $e >>~/getflow/$1_pnfs_$2_$3_rerun.txt
		linenumber=$((linenumber + 1))
	fi
	
done <$input

cp ~/getflow/run_$3$2.job ~/getflow/rerun_$3$2.job
sed -i "s@^Queue.*@Queue $linenumber@" ~/getflow/rerun_$3$2.job
sed -i "s@^Executable.*@Executable   = /usatlas/u/cher97/getflow/rerunloop.sh@" ~/getflow/rerun_$3$2.job
condor_submit ~/getflow/rerun_$3$2.job
