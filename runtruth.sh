#!/bin/bash

input=~/getflow/txts/$1_runlist.txt
#cat $input
#cat ~/getflow/$1_runlist.txt
#./runtruth.sh (no 1 tag):Truth220211.1 (no 2 eta lim):2.5 (no 3 truth pt lim):1.0
#./runtruth.sh Truth220211.1 2.5 1.0
#echo $1
linenumber=0
bold=$(tput bold)
normal=$(tput sgr0)
>~/getflow/txts/$1_log.txt

while IFS= read -r line <&3; do
	echo 'line_'${bold}$linenumber${normal}'-------------------------------------------------------------'
	echo 'line_'$linenumber'-------------------------------------------------------------'>>~/getflow/txts/$1_log.txt

if [ "$line" = "" ]; then
break;
fi
	b=${line#*'mc'}
	c=${b%%.*}    #data campaign
	d=${line##*.} #production tag

	if [ "$3" = "" ]; then
		ptTruthCut=1.0
	else
		ptTruthCut=$3
	fi

	if [ "$2" = "" ]; then
		eta=2.5
	else
		eta=$2
	fi

	echo ${bold}Dataset:${normal}' '$line
	echo ${bold}Specs:${normal}-------------------------------------------------------------
	#~/getflow/GetPHYSHI_single.sh $line $c $d
	#echo $c
	echo ${bold}eta range:${normal}' '$eta
	echo ${bold}pT Truth cut:${normal}' '$ptTruthCut

	echo 'Dataset: '$line>>~/getflow/txts/$1_log.txt
	echo Specs:------------------------------------------------------------->>~/getflow/txts/$1_log.txt
	#~/getflow/GetPHYSHI_single.sh $line $c $d
	#echo $c
	echo 'eta range: '$2>>~/getflow/txts/$1_log.txt
	echo 'pT Truth cut: '$ptTruthCut>>~/getflow/txts/$1_log.txt
	co=$c'_'$d
	#echo $co

	cp ~/getflow/condors/run_temp.job ~/getflow/condors/runtruth_$co_$1_$2_$3.job

	sed -i "s@^Executable.*@Executable   = /usatlas/u/cher97/getflow/runtruthloop.sh@" ~/getflow/condors/runtruth_$co_$1_$2_$3.job
	sed -i "s@^Arguments.*@Arguments       = $1 _pnfs $co \$(Process) $eta $ptTruthCut@" ~/getflow/condors/runtruth_$co_$1_$2_$3.job
	nof=$(((wc -l <~/getflow/txts/$co\_root_pnfs.txt)/4))
	#nof=5
	sed -i "s@^Queue.*@Queue $nof@" ~/getflow/condors/runtruth_$co_$1_$2_$3.job
	#cat run_PC$c.job
echo '-------------------------------------------------------------------'
echo '-------------------------------------------------------------------'>>~/getflow/txts/$1_log.txt

	#exec 0<&1

		read -p "Do you wish to remove old folder and rerun? (y/n) " answer
		if [[ $answer =~ ^[Yy]$ ]]; then
			echo "deleting original run folder"
			rm -rf /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$co'_EVNTTruth_'$2_$3/
		else
			echo "writing to old folder"
		fi

	mkdir -p /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$co'_EVNTTruth_'$2_$3/
	echo $1_pnfs_$co'_EVNTTruth_'$2_$3
	echo $1_pnfs_$co'_EVNTTruth_'$2_$3>>~/getflow/txts/$1_log.txt
	#cat ~/getflow/condors/runtruth_$co_$1_$2_$3.job
	condor_submit ~/getflow/condors/runtruth_$co_$1_$2_$3.job
	linenumber=$((linenumber + 1))
	echo 'line_-------------------------------------------------------------'>>~/getflow/txts/$1_log.txt
echo 'line_'${bold}$linenumber${normal}'-------------------------------------------------------------'
done 3<$input
