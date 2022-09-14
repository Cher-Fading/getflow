#!/bin/bash

input=~/getflow/txts/$3runall_runlist.txt
raccount

#./runall.sh no1:location no2:MCE211203.1 no3:mc18jet no4: optional, subsampling no5:optional combine m files 
#copy and open to be edited steering macro
mkdir -p ~/getflow/py/$1
mkdir -p ~/getflow/condors/$1
mkdir -p /atlasgpfs01/usatlas/data/cher97/$1

cd ~/$1
git tag -a $2 -m "$2"
git push --tags

cp ~/$1/source/MyAnalysis/share/ATestRun_eljob_local.py ~/getflow/py/$1/ATestRun_eljob$1_$2_$3.py
sed -i "s@.*job.options().setDouble( ROOT.EL.Job.optMaxEvents,.*@#job.options().setDouble( ROOT.EL.Job.optMaxEvents, 100)@" ~/getflow/py/$1/ATestRun_eljob$1_$2_$3.py
sed -i "s@.*alg.Verbose.*@alg.Verbose = False@" ~/getflow/py/$1/ATestRun_eljob$1_$2_$3.py
emacs ~/getflow/py/$1/ATestRun_eljob$1_$2_$3.py
template=$1_$2_$3
linenumber=1

if [ "$4" == "" ]; then
    nsubs=1
else
    nsubs=$4
fi

if [ "$5" == "" ]; then
    comb=1
else
    comb=$5
fi

while IFS= read -r line <&3; do
    echo 'line_'${bold}$linenumber${normal}'-------------------------------------------------------------'
    folder=$1/$1_$2_$3_$linenumber
    cp ~/getflow/py/$1/ATestRun_eljob$1_$2_$3.py ~/getflow/py/$folder'ATestRun_eljob.py'
    JZ=-1
    if [[ "$3" = *"mc"*"jet"* ]]; then
        tmps=${line#*JZ}
        JZ=${tmps:0:1}
        sed -i "s@.*alg.JZ.*@alg.JZ = $JZ@" ~/getflow/py/$folder'ATestRun_eljob.py'
    fi

    if [ "$line" = "" ]; then
        break
    fi

    cp ~/getflow/condors/run_temp.job ~/getflow/condors/$folder'_runall.job'

    sed -i "s@^Executable.*@Executable   = /usatlas/u/cher97/getflow/runallloop.sh@" ~/getflow/condors/$folder'_runall.job'
    sed -i "s@^Arguments.*@Arguments       = \$(Process) $folder $line $nsubs $comb@" ~/getflow/condors/$folder'_runall.job'
    nofful=$(wc -l <~/getflow/txts/$line.txt)
    nof=$((nofful/comb))
    sed -i "s@^Queue.*@Queue $nof@" ~/getflow/condors/$folder'_runall.job'

    #exec 0<&1

    read -p "Do you wish to remove old folder and rerun? (y/n) " answer
    if [[ $answer =~ ^[Yy]$ ]]; then
        echo "deleting original run folder"
        rm -rf /atlasgpfs01/usatlas/data/cher97/$folder/
    else
        echo "writing to old folder"
    fi

    mkdir -p /atlasgpfs01/usatlas/data/cher97/$folder/

    #cat ~/getflow/condors/$folder'_runall.job'
    condor_submit ~/getflow/condors/$folder'_runall.job'
    linenumber=$((linenumber + 1))
done 3<$input
