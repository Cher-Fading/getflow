#!/bin/bash
#input="/atlasgpfs01/usatlas/data/cher97/mc16_5TeV.txt"
# ./runallloop.sh no1 process# no2 foldername no3 nsubs no4 nf (number of files to be merged each round)
# for large dataset, use pnfs for storage

dest=/atlasgpfs01/usatlas/data/cher97/$2/sub$3.$1
ls $dest/mce*.root >$dest/totalfiles.txt
totn=$(wc -l <$dest/totalfiles.txt)
nf=$4
n=$((totn/nf))
python /usatlas/u/cher97/getflow/splitfiles.py $dest totalfiles $4
for j in $(seq 0 $((n-1)) ); do
        cd $dest
        mkdir -p tot$1.$j
        cd tot$1.$j
        echo 'pwd'$1'_'$j'_'$PWD
        hadd $dest/tot$1.$j/sub$3.$1.$j.root @$dest/totalfiles$j.txt
	#cat $dest/totalfiles$j.txt
input=$dest/totalfiles$j.txt
while IFS= read -r line <&3; do
        find $line -size 0 >$dest/tot$1.$j/sub$3.$1.$j'_size0.txt'
done 3<$input

done
mkdir -p $dest/tots
hadd $dest/tots/sub$3.$1.root $dest/tot$1.*/sub$3.$1.*.root

