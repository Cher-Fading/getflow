#!/bin/bash
#./haddrunlist.sh $1(part1) $2(part2) $3(iterate begin) $4(iterate end)
dest=/atlasgpfs01/usatlas/data/cher97
cd $dest
for i in `seq $3 $4`;
do
	cd $dest/$1$i$2
	mkdir -p tot
	cd tot
	hadd $1$i$2.root ../*.root
done
cd $dest
mkdir $1$2
cd $1$2
hadd -f $1$2.root ../$1*$2/tot/*.root
