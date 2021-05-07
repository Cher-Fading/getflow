#!/bin/bash

cd /usatlas/scratch/cher97/
ls $1_pnfs_$2_$3 >~/getflow/$1_pnfs_$2_$3_stat.txt

input=~/getflow/$1_pnfs_$2_$3_stat.txt
#cat ~/getflow/$1_runlist.txt

linenumber=0
while IFS= read -r line; do
	b=${line#*'usatlas '}
	c=${b%%' '$4*}
	echo $c
	if [ "$c" == "0" ]; then
		$linenumber >>~/getflow/$1_pnfs_$2_$3_rerun.txt
	fi
	linenumber=$((linenumber + 1))
done <$input

cp ~/getflow/run_$3$2.job ~/getflow/rerun_$3$2.job
sed -i "s@^Queue.*@Queue $linenumber'@" ~/getflow/rerun_$3$2.job
sed -i "s@^Executable.*@Executable   = /usatlas/u/cher97/getflow/rerunloop.sh'@" ~/getflow/rerun_$3$2.job
condor_submit rerun_$3$2.job
