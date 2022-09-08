#!/bin/bash
#./haddrunlist.sh $1(masterfolder) $2(part1) $3(part2) $4(iterate begin) $5(iterate end) $6 True $7 filenumber_first_digit
# e.g. ./haddrunlist.sh spmethod spmethod_SPMethod220831.1_data18jet_ /sub1.0 1 1 True 1
dest=/atlasgpfs01/usatlas/data/cher97/$1
cd $dest
suffix=${3#*/}
prefix=${2%/*}
for j in $(seq 0 9); do
    for i in $(seq $4 $5); do
        cd $dest/$2$i$3
        mkdir -p tot$i.$j
        cd tot$i.$j
        echo 'pwd: '$PWD

        hadd $dest/$2$i$3/tot$i.$j/$prefix$i$suffix.root ../mce_$j*.root

        find ../*.root -size 0
        if [ "$6" == "delete" ]; then
            read -p "Do you wish to remove old folder and rerun? (y/n) " answer
            if [[ $answer =~ ^[Yy]$ ]]; then
                echo "deleting original root"
                mv ../*_0_0.root .
                mv ../*_0_0.txt .
                mv ../*_0_0*.py .
                rm ../*.root
                rm ../*.py
                rm ../*.txt
                echo 'remove'
            else
                echo "keeping all files"
            fi
        fi
    done
cd $dest/$2$i$3
        mkdir -p tots$i
hadd -f $dest/$2$i$3/tots$i/$2$i$suffix.root $dest/$2$i$3/tot$i.*/$2$i$suffix.root
done
cd $dest/$2$i$3
        mkdir -p tot
hadd -f $dest/$2$i$3/tot/$2$suffix.root $dest/$2$i$3/tots*/$2$i$suffix.root
