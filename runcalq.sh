#!/bin/bash
#./runcalq.sh Flow210505.1 Calq210505.1 2
input=~/getflow/$1_runlist.txt
#cat ~/getflow/$1_runlist.txt



linenumber=0
while IFS= read -r line; do
	b=${line#*data18_hi.00}
	c=${b%%.*}
	d=${line#*AOD.}
	ls '/pnfs/usatlas.bnl.gov/users/cher97/'$1'_pnfs_'$c'_PC/tempin'$c'_PC_*.root' > '~/getflow/'$1'_pnfs_'$c'_PC_rootlist.txt'
	cp ~/getflow/run_temp.job ~/getflow/runcalq_PC$c.job
    sed -i "s@^Executable.*@Executable   = /usatlas/u/cher97/getflow/runcalqloop.sh@" ~/getflow/runcalq_PC$c.job
	sed -i "s@^Arguments.*@Arguments       = $1 _pnfs $c PC \$(Process) $2 $3@" ~/getflow/runcalq_PC$c.job
	nof=$(wc -l < '~/getflow/'$1'_pnfs_'$c'_PC_rootlist.txt')
	sed -i "s@^Queue.*@Queue $nof@" ~/getflow/runcalq_PC$c.job
	cat runcalq_PC$c.job
	#condor_submit run_PC$c.job
    
    ls '/pnfs/usatlas.bnl.gov/users/cher97/'$1'_pnfs_'$c'_PC/tempin'$c'_PC_*.root' > '~/getflow/'$1'_pnfs_'$c'_CC_rootlist.txt'
	cp ~/getflow/run_temp.job ~/getflow/runcalq_CC$c.job
    sed -i "s@^Executable.*Executable   = /usatlas/u/cher97/getflow/runcalqloop.sh" ~/getflow/runcalq_CC$c.job
	sed -i "s@^Arguments.*@Arguments       = $1 _pnfs $c CC \$(Process) $2 $3@" ~/getflow/runcalq_CC$c.job
	nof=$(wc -l < '~/getflow/'$1'_pnfs_'$c'_CC_rootlist.txt')
	sed -i "s@^Queue.*@Queue $nof@" ~/getflow/runcalq_CC$c.job
	cat runcalq_CC$c.job
	#condor_submit run_CC$c.job

	linenumber=$((linenumber + 1))
done <$input
