#!/bin/bash

#first create a list of files needed to check zero for. By default this code hard code peb stream run list
#dest is destimation of the filelist

#./countgridevt.sh dest filelist 
input=$1/$2

#check which files have zero events
mkdir -p ~/getflow/txts/counts/$2
zerofile=~/getflow/txts/counts/$2/$2'_zero.txt'
>$zerofile
output=/usatlas/u/cher97/getflow/txts/counts/$2/$2'_count.csv'
echo 'rootfile,date,run,stream,total,npu,pu'>$output

while IFS= read -r line; do
filename=$line
if [[ "$line" == *".0036"* ]]; then
tmp=${line%%.0036*}
echo $tmp
date=${tmp: -7}
echo $date
tmp=${line#*.0036}
echo $tmp
run=36${tmp:0:4}
echo $run
tmp=${line#*calibration_}
echo $tmp
stream=${tmp:0:5}
echo $stream
tmp=${line#*.k}
prod='k'${tmp:0:10}
label=$date','$run','$stream','$prod
dataset='data18_hi.00'$run'.calibration_'$stream'.merge.AOD.'$prod
echo $label
echo $dataset

else 
echo "hmmm no 0036"
exit 1
fi
text=$(root -q -l -b '~/atlasstyle-00-04-02/countevtall.c("'$filename'","'$label'","'$output'")')
if [[ "$text" == *"no events"* ]]; then
echo $dataset>>$zerofile
fi

done <$input

#count missing files
outfile=~/getflow/txts/counts/$2/$2_miss.txt
root -q -l -b '~/getflow/compare2lists.c("/usatlas/u/cher97/getflow/txts/runlist.txt","'$1'/'$2'","'$outfile'")'
