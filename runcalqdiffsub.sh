#!/bin/bash
#./runcalqdiffsub.sh Flow210602.1 Calq210704.1 2 20
input=~/getflow/$1_runlist.txt
#cat ~/getflow/$1_runlist.txt

linenumber=0
while IFS= read -r line; do
	b=${line#*data18_hi.00}
	c=${b%%.*}
	d=${line#*AOD.}
	cd ~/getflow
	#python pnfs_ls.py -l -o ~/getflow/$1_pnfs_$c'_PC_rootlist.txt' /pnfs/usatlas.bnl.gov/users/cher97/$1_pnfs_$c'_PC/tempin'$c'_PC_*.root'
	#python pnfs_ls.py -l -o ~/getflow/$1_pnfs_$c'_CC_rootlist.txt' /pnfs/usatlas.bnl.gov/users/cher97/$1_pnfs_$c'_CC/tempin'$c'_CC_*.root'
	chmod +777 /pnfs/usatlas.bnl.gov/users/cher97/$1_pnfs_$c'_PC'
	mkdir -p /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$c'_PC_calq_subdiff'$2_v$3
	chmod +777 /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$c'_PC_calq_subdiff'$2_v$3
	chmod +777 /pnfs/usatlas.bnl.gov/users/cher97/$1_pnfs_$c'_CC'
	mkdir -p /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$c'_CC_calq_subdiff'$2_v$3
	chmod +777 /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$c'_CC_calq_subdiff'$2_v$3
	for ((i = 1; i <= $4; i++)); do
		cp ~/getflow/run_temp.job ~/getflow/$1$2runcalqdiffsub$4_PC$c$i.job
		sed -i "s@^Executable.*@Executable   = /usatlas/u/cher97/getflow/runcalqdiffsubloop.sh@" ~/getflow/$1$2runcalqdiffsub$4_PC$c$i.job
		sed -i "s@^Arguments.*@Arguments       = $1 _pnfs $c PC \$(Process) $2 $3 $4 $i@" ~/getflow/$1$2runcalqdiffsub$4_PC$c$i.job
		nof=$(($(wc -l <~/getflow/$1_pnfs_$c'_PC_rootlist.txt') - 2))
		sed -i "s@^Queue.*@Queue $nof@" ~/getflow/$1$2runcalqdiffsub$4_PC$c$i.job
		#cat runcalq_PC$c.job
		#rm -rf /pnfs/usatlas.bnl.gov/users/cher97/$1_pnfs_$c'_PC_calq_subdiff'$2_v$3
		condor_submit $1$2runcalqdiffsub$4_PC$c$i.job

		cp ~/getflow/run_temp.job ~/getflow/$1$2runcalqdiffsub$4_CC$c$i.job
		sed -i "s@^Executable.*@Executable   = /usatlas/u/cher97/getflow/runcalqdiffsubloop.sh@" ~/getflow/$1$2runcalqdiffsub$4_CC$c$i.job
		sed -i "s@^Arguments.*@Arguments       = $1 _pnfs $c CC \$(Process) $2 $3 $4 $i@" ~/getflow/$1$2runcalqdiffsub$4_CC$c$i.job
		nof=$(($(wc -l <~/getflow/$1_pnfs_$c'_CC_rootlist.txt') - 2))
		sed -i "s@^Queue.*@Queue $nof@" ~/getflow/$1$2runcalqdiffsub$4_CC$c$i.job
		#cat runcalq_CC$c.job

		#rm -rf /pnfs/usatlas.bnl.gov/users/cher97/$1_pnfs_$c'_CC_calq_subdiff'$2_v$3
		condor_submit $1$2runcalqdiffsub$4_CC$c$i.job
	done
	linenumber=$((linenumber + 1))
done <$input
