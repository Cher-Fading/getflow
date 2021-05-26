#!/bin/bash

input=~/getflow/$1_runlist.txt
#cat ~/getflow/$1_runlist.txt



linenumber=0
while IFS= read -r line; do
	b=${line#*data18_hi.00}
	c=${b%%.*}
	d=${line#*AOD.}
	~/getflow/GetLOCALGROUPDISK_single.sh $c $d
	mkdir -p /pnfs/usatlas.bnl.gov/users/cher97/$1_pnfs_$d_PC/
	chmod +777 /pnfs/usatlas.bnl.gov/users/cher97/$1_pnfs_$d_PC/
	mkdir -p /pnfs/usatlas.bnl.gov/users/cher97/$1_pnfs_$d_CC/
	chmod +777 /pnfs/usatlas.bnl.gov/users/cher97/$1_pnfs_$d_CC/

	cp ~/getflow/run_temp.job ~/getflow/run_PC$c.job
	sed -i "s@^Arguments.*@Arguments       = $1 _pnfs $c PC \$(Process)@" ~/getflow/run_PC$c.job
	nof=$(wc -l < ~/getflow/$c\_PC_root_pnfs.txt)
	sed -i "s@^Queue.*@Queue $nof@" ~/getflow/run_PC$c.job
	#cat run_PC$c.job
	condor_submit run_PC$c.job
    
	cp ~/getflow/run_temp.job ~/getflow/run_CC$c.job#
	sed -i "s@^Arguments.*@Arguments       = $1 _pnfs $c CC \$(Process)@" ~/getflow/run_CC$c.job
	nof=$(wc -l < ~/getflow/$c\_CC_root_pnfs.txt)
	sed -i "s@^Queue.*@Queue $nof@" ~/getflow/run_CC$c.job
	#cat run_CC$c.job
	condor_submit run_CC$c.job

	linenumber=$((linenumber + 1))
done <$input
