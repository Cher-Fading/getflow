#!/bin/bash
#./runcalqsub.sh Flow210505.1 Calq210505.1 2 20
input=~/getflow/$1_runlist.txt
#cat ~/getflow/$1_runlist.txt

linenumber=0
while IFS= read -r line; do
	b=${line#*data18_hi.00}
	c=${b%%.*}
	d=${line#*AOD.}
	cd ~/getflow
	rm ~/getflow/$1_pnfs_$c'_PC_rootlist.txt'
	python pnfs_ls.py -l -o ~/getflow/$1_pnfs_$c'_PC_rootlist.txt' /pnfs/usatlas.bnl.gov/users/cher97/$1_pnfs_$c'_PC/tempin'$c'_PC_*.root'
	chmod +777 /pnfs/usatlas.bnl.gov/users/cher97/$1_pnfs_$c'_PC'
	cp ~/getflow/run_temp.job ~/getflow/runcalqsub_PC$c.job
	sed -i "s@^Executable.*@Executable   = /usatlas/u/cher97/getflow/runcalqsubloop.sh@" ~/getflow/runcalqsub_PC$c.job
	sed -i "s@^Arguments.*@Arguments       = $1 _pnfs $c PC \$(Process) $2 $3 $4@" ~/getflow/runcalqsub_PC$c.job
	nof=$(($(wc -l <~/getflow/$1_pnfs_$c'_PC_rootlist.txt') - 2))
	sed -i "s@^Queue.*@Queue $nof@" ~/getflow/runcalqsub_PC$c$i.job
	#cat runcalq_PC$c.job
	#rm -rf /pnfs/usatlas.bnl.gov/users/cher97/$1_pnfs_$c'_PC_calq_sub'$2_v$3
	#mkdir /pnfs/usatlas.bnl.gov/users/cher97/$1_pnfs_$c'_PC_calq_sub'$2_v$3
	#chmod +777 /pnfs/usatlas.bnl.gov/users/cher97/$1_pnfs_$c'_PC_calq_sub'$2_v$3
	rm -rf /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$c'_PC_calq_sub'$2_v$3
	mkdir /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$c'_PC_calq_sub'$2_v$3
	chmod +777 /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$c'_PC_calq_sub'$2_v$3
	condor_submit runcalqsub_PC$c.job

	cd ~/getflow
	rm ~/getflow/$1_pnfs_$c'_CC_rootlist.txt'
	python pnfs_ls.py -l -o ~/getflow/$1_pnfs_$c'_CC_rootlist.txt' /pnfs/usatlas.bnl.gov/users/cher97/$1_pnfs_$c'_CC/tempin'$c'_CC_*.root'
	chmod +777 /pnfs/usatlas.bnl.gov/users/cher97/$1_pnfs_$c'_CC'
	cp ~/getflow/run_temp.job ~/getflow/runcalqsub_CC$c.job
	sed -i "s@^Executable.*@Executable   = /usatlas/u/cher97/getflow/runcalqsubloop.sh@" ~/getflow/runcalqsub_CC$c.job
	sed -i "s@^Arguments.*@Arguments       = $1 _pnfs $c CC \$(Process) $2 $3 $4@" ~/getflow/runcalqsub_CC$c.job
	nof=$(($(wc -l <~/getflow/$1_pnfs_$c'_CC_rootlist.txt') - 2))
	sed -i "s@^Queue.*@Queue $nof@" ~/getflow/runcalqsub_CC$c.job
	#cat runcalq_CC$c.job

	#rm -rf /pnfs/usatlas.bnl.gov/users/cher97/$1_pnfs_$c'_CC_calq_sub'$2_v$3
	#mkdir /pnfs/usatlas.bnl.gov/users/cher97/$1_pnfs_$c'_CC_calq_sub'$2_v$3
	#chmod +777 /pnfs/usatlas.bnl.gov/users/cher97/$1_pnfs_$c'_CC_calq_sub'$2_v$3
	rm -rf /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$c'_CC_calq_sub'$2_v$3
	mkdir /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$c'_CC_calq_sub'$2_v$3
	chmod +777 /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$c'_CC_calq_sub'$2_v$3
	condor_submit runcalqsub_CC$c.job

	linenumber=$((linenumber + 1))
done <$input
