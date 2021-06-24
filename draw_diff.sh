#!/bin/bash
# ./draw_diff.sh Flow210602.1 Calq210526.1 365678 2
mkdir -p /atlasgpfs01/usatlas/data/cher97/$1_diff$2_v$4
cd /atlasgpfs01/usatlas/data/cher97/$1_diff$2_v$4
hadd $1_diff$2_v$4.root ../$1_pnfs_$3_PC_calq_diff$2_v$4/*.root ../$1_pnfs_$3_CC_calq_diff$2_v$4/*.root

cd ~/calq
#root -q 'draw_diff.C("'$1'","'$2'",'$4')'
