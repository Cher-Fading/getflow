#!/bin/bash

input=~/getflow/txts/$1_runlist.txt
#cat ~/getflow/$1_runlist.txt
# ./runsp.sh Qmean210916.1 True 0.5

linenumber=0
while IFS= read -r line; do
	b=${line#*mc}
	c=${b%%.*} #run number
	d=${line##*.} #production tag
	~/getflow/GetPHYSHI_single.sh $line $c $d

	cp ~/getflow/condors/run_temp.job ~/getflow/condors/runmc_$c_$1.job
	sed -i "s@^Arguments.*@Arguments       = $1 _pnfs $c PC \$(Process) $2 $3@" ~/getflow/condors/runmc$c_$1.job
	nof=$(wc -l <~/getflow/$c\_PC_root_pnfs.txt)
	sed -i "s@^Queue.*@Queue $nof@" ~/getflow/condors/runmc$c_$1.job
	#cat run_PC$c.job
	rm -rf /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$c'_PC_qmean_'$2_$3/
	mkdir /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$c'_PC_qmean_'$2_$3/
	cat ~/getflow/condors/runmc$c_$1.job
	#condor_submit ~/getflow/condors/runmc$c_$1.job

	linenumber=$((linenumber + 1))
done <$input
