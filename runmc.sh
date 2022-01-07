#!/bin/bash

input=~/getflow/txts/$1_runlist.txt
#cat $input
#cat ~/getflow/$1_runlist.txt
# ./runmc.sh MCE211203.1 1.0 0.3 HITight False
#echo $1
linenumber=0
raccount
while IFS= read -r line; do
	b=${line#*mc}
	c=${b%%.*} #run number
	d=${line##*.} #production tag
        echo here
        echo $line
	#~/getflow/GetPHYSHI_single.sh $line $c $d
	co=$c'_'$d
echo $co

	cp ~/getflow/condors/run_temp.job ~/getflow/condors/runmc_$co_$1_$2_$3_$4_$5.job
sed -i "s@^Executable.*@Executable   = /usatlas/u/cher97/getflow/runmcloop.sh@" ~/getflow/condors/runmc_$co_$1_$2_$3_$4_$5.job
	sed -i "s@^Arguments.*@Arguments       = $1 _pnfs $co \$(Process) $2 $3 $4 $5@" ~/getflow/condors/runmc_$co_$1_$2_$3_$4_$5.job
	nof=$(wc -l <~/getflow/txts/$co\_root_pnfs.txt)
	sed -i "s@^Queue.*@Queue $nof@" ~/getflow/condors/runmc_$co_$1_$2_$3_$4_$5.job
	#cat run_PC$c.job
	rm -rf /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$co'_MCEff_'$2_$3_$4_$5/
	mkdir /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$co'_MCEff_'$2_$3_$4_$5/
	#cat ~/getflow/condors/runmc_$co_$1_$2_$3_$4.job
	condor_submit ~/getflow/condors/runmc_$co_$1_$2_$3_$4_$5.job
	linenumber=$((linenumber + 1))
done <$input
