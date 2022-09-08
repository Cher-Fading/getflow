#!/bin/bash
#input="/atlasgpfs01/usatlas/data/cher97/mc16_5TeV.txt"
# ./runallloop.sh no1 process# no2 foldername no3 nsubs
# for large dataset, use pnfs for storage

dest=/atlasgpfs01/usatlas/data/cher97/$2/sub$3.$1
for j in $(seq 0 9); do
        cd $dest
        mkdir -p tot$1.$j
        cd tot$1.$j
        echo 'pwd'$1'_'$j'_'$PWD
        hadd $dest/tot$1.$j/$2sub$3.$1.$j.root ../mce_$j*.root

        find ../*.root -size 0 >$dest/tot$j/$2sub$3.$1.$j_size0.txt
done
mkdir -p $dest/tots
hadd -f $dest/tots/$2sub$3.$1.root $dest/tots/$2sub$3.$1.*.root

