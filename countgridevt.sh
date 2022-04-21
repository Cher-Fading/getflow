#!/bin/bash

#./countgridevt.sh filelist
input=$1
mkdir -p ~/getflow/txts/counts/
output=txts/counts/$1'_count.csv'
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
label=$date','$run','$stream
echo $label
else 
echo "hmmm no 0036"
exit 1
fi
root -q -l -b '~/atlasstyle-00-04-02/countevtall.c("'$filename'","'$label'","'$output'")'

done <$input

