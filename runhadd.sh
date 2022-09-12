#!/bin/bash
#./runhadd.sh $1 foldername:spmethod $2 tag $3 data $4:nsubs $5:do nfiles round
input=~/getflow/txts/$3runall_runlist.txt

linenumber=1

if [ "$4" == "" ]; then
    nsubs=1
else
    nsubs=$4
fi

while IFS= read -r line <&3; do
    echo 'line_'${bold}$linenumber${normal}'-------------------------------------------------------------'
    folder=$1/$1_$2_$3_$linenumber

    if [ "$line" = "" ]; then
        break
    fi

    cp ~/getflow/condors/run_temp.job ~/getflow/condors/$folder'_runhadd.job'

    sed -i "s@^Executable.*@Executable   = /usatlas/u/cher97/getflow/runhaddloop.sh@" ~/getflow/condors/$folder'_runhadd.job'
    sed -i "s@^Arguments.*@Arguments       = \$(Process) $folder $nsubs $5@" ~/getflow/condors/$folder'_runhadd.job'
    sed -i "s@^Queue.*@Queue $nsubs@" ~/getflow/condors/$folder'_runhadd.job'

    condor_submit ~/getflow/condors/$folder'_runhadd.job'
    linenumber=$((linenumber + 1))
done 3<$input
