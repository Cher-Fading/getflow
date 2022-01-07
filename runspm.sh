#!/bin/bash

input=~/getflow/txts/$1_runlist.txt
#cat ~/getflow/$1_runlist.txt
# ./runspm.sh SPMethod211006.1 20


linenumber=0
while IFS= read -r line; do
	b=${line#*data18_hi.00}
	c=${b%%.*}      #run number
	d=${line#*AOD.} #production tag
	~/getflow/GetLOCALGROUPDISK_single.sh $c $d

	cp ~/getflow/condors/run_temp.job ~/getflow/condors/runspm_PC$c_$d_$1_sub$2.job
	sed -i "s@^Arguments.*@Arguments       = $1 _pnfs $c $d PC \$(Process) $2@" ~/getflow/condors/runspm_PC$c_$d_$1_sub$2.job
	sed -i "s@^Executable.*@Executable   = /usatlas/u/cher97/getflow/runspmloop.sh@" ~/getflow/condors/runspm_PC$c_$d_$1_sub$2.job
	nof=$(wc -l <~/getflow/txts/$c\_PC_root_pnfs.txt)
	sed -i "s@^Queue.*@Queue $nof@" ~/getflow/condors/runspm_PC$c_$d_$1_sub$2.job
	#cat run_PC$c.job
	rm -rf /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$c'_'$d'_PC_spmethod_sub'$2'/'
	mkdir /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$c'_'$d'_PC_spmethod_sub'$2'/'
	for ((i = 0; i < $2; i++)); do
		mkdir /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$c'_'$d'_PC_spmethod_sub'$2'/sub'$i
	done
#echo /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$c'_'$d'_PC_spmethod_sub'$2'/'
	#cat ~/getflow/condors/runspm_PC$c_$d_$1_sub$2.job
	condor_submit ~/getflow/condors/runspm_PC$c_$d_$1_sub$2.job

	cp ~/getflow/condors/run_temp.job ~/getflow/condors/runspm_CC$c_$d_$1_sub$2.job
	sed -i "s@^Arguments.*@Arguments       = $1 _pnfs $c $d CC \$(Process) $2@" ~/getflow/condors/runspm_CC$c_$d_$1_sub$2.job
	sed -i "s@^Executable.*@Executable   = /usatlas/u/cher97/getflow/runspmloop.sh@" ~/getflow/condors/runspm_CC$c_$d_$1_sub$2.job
	nof=$(wc -l <~/getflow/txts/$c\_CC_root_pnfs.txt)
	sed -i "s@^Queue.*@Queue $nof@" ~/getflow/condors/runspm_CC$c_$d_$1_sub$2.job
	#cat run_CC$c.job
	rm -rf /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$c'_'$d'_CC_spmethod_sub'$2/
	mkdir /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$c'_'$d'_CC_spmethod_sub'$2/
	for ((i = 0; i < $2; i++)); do
		mkdir /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$c'_'$d'_CC_spmethod_sub'$2'/sub'$i
	done
	#cat ~/getflow/condors//runspm_CC$c_$d_$1_sub$2.job
	condor_submit ~/getflow/condors/runspm_CC$c_$d_$1_sub$2.job

	linenumber=$((linenumber + 1))
done <$input
