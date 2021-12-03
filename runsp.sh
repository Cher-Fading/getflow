#!/bin/bash

input=~/getflow/txts/$1_runlist.txt
#cat ~/getflow/$1_runlist.txt
# ./runsp.sh Qmean210916.1 True 0.5

linenumber=0
while IFS= read -r line; do
	b=${line#*data18_hi.00}
	c=${b%%.*} #run number
	d=${line#*AOD.} #production tag
	~/getflow/GetLOCALGROUPDISK_single.sh $c $d

	cp ~/getflow/condors/run_temp.job ~/getflow/condors/runsp_PC$c_$1.job
	sed -i "s@^Arguments.*@Arguments       = $1 _pnfs $c PC \$(Process) $2 $3@" ~/getflow/condors/runsp_PC$c_$1.job
sed -i "s@^Executable.*@Executable   = /usatlas/u/cher97/getflow/runsploop.sh@" ~/getflow/condors/runsp_PC$c_$1.job
	nof=$(wc -l <~/getflow/txts/$c\_PC_root_pnfs.txt)
	sed -i "s@^Queue.*@Queue $nof@" ~/getflow/condors/runsp_PC$c_$1.job
	#cat run_PC$c.job
	rm -rf /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$c'_PC_qmean_'$2_$3/
	mkdir /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$c'_PC_qmean_'$2_$3/
	#cat ~/getflow/condors/runsp_PC$c_$1.job
	condor_submit ~/getflow/condors/runsp_PC$c_$1.job

	cp ~/getflow/condors/run_temp.job ~/getflow/condors/runsp_CC$c_$1.job
	sed -i "s@^Arguments.*@Arguments       = $1 _pnfs $c CC \$(Process) $2 $3@" ~/getflow/condors/runsp_CC$c_$1.job
sed -i "s@^Executable.*@Executable   = /usatlas/u/cher97/getflow/runsploop.sh@" ~/getflow/condors/runsp_CC$c_$1.job
	nof=$(wc -l <~/getflow/txts/$c\_CC_root_pnfs.txt)
	sed -i "s@^Queue.*@Queue $nof@" ~/getflow/condors/runsp_CC$c_$1.job
	#cat run_CC$c.job
	rm -rf /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$c'_CC_qmean_'$2_$3/
	mkdir /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$c'_CC_qmean_'$2_$3/
	#cat ~/getflow/condors/runsp_CC$c_$1.job
	condor_submit ~/getflow/condors/runsp_CC$c_$1.job

	linenumber=$((linenumber + 1))
done <$input
