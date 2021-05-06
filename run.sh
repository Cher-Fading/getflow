cd ~/flow
asetup --restore
cd build
source x86_64-slc7-gcc8-opt/setup.sh

input="~/getflow/$1_runlist.txt"

linenumber=0
while IFS= read -r line; do
    cp ~/getflow/run_temp.job ~/getflow/run_PC$line.job
    sed -i "s@^Arguments.*@Arguments       = $1 _pnfs $line PC \$(Process)'@" ~/getflow/run_PC$line.job
    condor_submit run_PC$line.job
    
    cp ~/getflow/run_temp.job ~/getflow/run_CC$line.job
    sed -i "s@^Arguments.*@Arguments       = $1 _pnfs $line CC \$(Process)'@" ~/getflow/run_CC$line.job
    condor_submit run_CC$line.job
    
	linenumber=$((linenumber + 1))
done <"$input"