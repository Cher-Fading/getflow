#!/bin/bash
# ./draw.sh Flow210511.1 Calq210520.1 Calq210526.1 365678 2 20 2
if [ $7 -ge $6 ]; then
    mkdir -p /atlasgpfs01/usatlas/data/cher97/$1_$2_v$5
    cd /atlasgpfs01/usatlas/data/cher97/$1_$2_v$5
    hadd $1_$2_v$5.root ../$1_pnfs_$4_PC_$3_v$5/*calq.root ../$1_pnfs_$4_CC_$3_v$5/*calq.root
    cd ~/calq
    #root -q 'draw.C("'$1'","'$2'","'$3'",'$5','$6')''
else
    mkdir -p /atlasgpfs01/usatlas/data/cher97/$1_sub$3_v$5_$6
    cd /atlasgpfs01/usatlas/data/cher97/$1_sub$3_v$5_$6
    #hadd $1_$2_v$5.root ../$1_pnfs_$4_PC_calq_diff$2_v$5/*.root ../$1_pnfs_$4_PC_calq_diff$2_v$5/*.root
    hadd $1_$3sub_v$5_$6_$7.root ../$1_pnfs_$4_PC_calq_sub$3_v$5/*$6_$7.root ../$1_pnfs_$4_CC_calq_sub$3_v$5/*$6_$7.root
fi
