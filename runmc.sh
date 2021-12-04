#!/bin/bash

input=~/getflow/txts/$1_runlist.txt
#cat ~/getflow/$1_runlist.txt
# ./runmc.sh MCE211203.1 1.0 0.3

linenumber=0
while IFS= read -r line; do
	b=${line#*mc}
	c=${b%%.*} #run number
	d=${line##*.} #production tag
	~/getflow/GetPHYSHI_single.sh $line $c $d
	co=$c'_'$d

	cp ~/getflow/condors/run_temp.job ~/getflow/condors/runmc_$co_$2_$3.job
	sed -i "s@^Arguments.*@Arguments       = $1 _pnfs $co \$(Process) $2 $3@" ~/getflow/condors/runmc$co_$2_$3.job
	nof=$(wc -l <~/getflow/$co\_root_pnfs.txt)
	sed -i "s@^Queue.*@Queue $nof@" ~/getflow/condors/runmc$c_$1.job
	#cat run_PC$c.job
	rm -rf /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$co'_MCEff_'$2_$3/
	mkdir /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$co'_MCEff_'$2_$3/
	cat ~/getflow/condors/runmc$co_$2_$3.job
	#condor_submit ~/getflow/condors/runmc$c_$1.job

	linenumber=$((linenumber + 1))
done <$input
