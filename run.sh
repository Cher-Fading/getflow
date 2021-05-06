#!/bin/bash
cd ~/flow
asetup --restore
cd build
source x86_64-slc7-gcc8-opt/setup.sh

input="~/getflow/$1_runlist.txt"

linenumber=0
while IFS= read -r line; do
    b=${line#*data18_hi.00}
    c=${b%%.*}
    d=${line#*AOD.}
    ~/getflow/GetLOCALGROUPDISK_single.sh $c $d
	cp ~/getflow/run_temp.job ~/getflow/run_PC$c.job
	sed -i "s@^Arguments.*@Arguments       = $1 _pnfs $c PC \$(Process)'@" ~/getflow/run_PC$c.job
	condor_submit run_PC$c.job
    
	cp ~/getflow/run_temp.job ~/getflow/run_CC$c.job
	sed -i "s@^Arguments.*@Arguments       = $1 _pnfs $c CC \$(Process)'@" ~/getflow/run_CC$c.job
	condor_submit run_CC$c.job

	linenumber=$((linenumber + 1))
done <"$input"
