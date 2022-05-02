#!/bin/bash
#./haddrunlist.sh $1(masterfolder) $2(part1) $3(part2) $4(iterate begin) $5(iterate end) $6 True
dest=/atlasgpfs01/usatlas/data/cher97/$1
cd $dest
for i in `seq $4 $5`;
do
	cd $dest/$2$i$3
	mkdir -p tot
	cd tot
	hadd $2$i$3.root ../*.root
mv ../*_0_0.root .
mv ../*_0_0.txt .
mv ../*_0_0*.py .
zero=$(find ../*.root -size 0)
if [ "$6" == "" ]; then
        rm ../*.root
rm ../*.py
rm ../*.txt
    fi
done
cd $dest
hadd -f $2$3.root $2*$3/tot/*.root
