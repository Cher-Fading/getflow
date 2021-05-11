#!/bin/bash
#./runcalq.sh Flow210505.1 Calq210505.1 2
input=~/getflow/$1_runlist.txt
#cat ~/getflow/$1_runlist.txt


linenumber=0
while IFS= read -r line; do
	b=${line#*data18_hi.00}
	c=${b%%.*}
	d=${line#*AOD.}
cd ~/getflow
	python pnfs_ls.py -l -o ~/getflow/$1_pnfs_$c'_PC_rootlist.txt' /pnfs/usatlas.bnl.gov/users/cher97/$1_pnfs_$c'_PC/tempin'$c'_PC_*.root'
	chmod +777 /pnfs/usatlas.bnl.gov/users/cher97/$1_pnfs_$c'_PC'
	cp ~/getflow/run_temp.job ~/getflow/runcalq_PC$c.job
        sed -i "s@^Executable.*@Executable   = /usatlas/u/cher97/getflow/runcalqloop.sh@" ~/getflow/runcalq_PC$c.job
	sed -i "s@^Arguments.*@Arguments       = $1 _pnfs $c PC \$(Process) $2 $3@" ~/getflow/runcalq_PC$c.job
	nof=$(($(wc -l < ~/getflow/$1_pnfs_$c'_PC_rootlist.txt')-2))
	sed -i "s@^Queue.*@Queue $nof@" ~/getflow/runcalq_PC$c.job
	#cat runcalq_PC$c.job
	#mkdir -p /pnfs/usatlas.bnl.gov/users/cher97/$1_pnfs_$c'_PC_calq_'$2_v$3
	condor_submit runcalq_PC$c.job
    
	cd ~/getflow
        python pnfs_ls.py -l -o ~/getflow/$1_pnfs_$c'_CC_rootlist.txt' /pnfs/usatlas.bnl.gov/users/cher97/$1_pnfs_$c'_CC/tempin'$c'_CC_*.root'
	chmod +777 /pnfs/usatlas.bnl.gov/users/cher97/$1_pnfs_$c'_CC'
	cp ~/getflow/run_temp.job ~/getflow/runcalq_CC$c.job
        sed -i "s@^Executable.*@Executable   = /usatlas/u/cher97/getflow/runcalqloop.sh@" ~/getflow/runcalq_CC$c.job
	sed -i "s@^Arguments.*@Arguments       = $1 _pnfs $c CC \$(Process) $2 $3@" ~/getflow/runcalq_CC$c.job
	nof=$(($(wc -l < ~/getflow/$1_pnfs_$c'_CC_rootlist.txt')-2))
	sed -i "s@^Queue.*@Queue $nof@" ~/getflow/runcalq_CC$c.job
	#cat runcalq_CC$c.job
	#mkdir -p /pnfs/usatlas.bnl.gov/users/cher97/$1_pnfs_$c'_CC_calq_'$2_v$3
	condor_submit runcalq_CC$c.job

	linenumber=$((linenumber + 1))
done <$input
