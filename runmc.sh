#!/bin/bash

input=~/getflow/txts/$1_runlist.txt
#cat $input
#cat ~/getflow/$1_runlist.txt
# ./runmc.sh no1:MCE211203.1 no2:1.5(etarange) no3:0.3(min prob) no4:HITight no5:False(do eff) no6:mc no7:0.5(optional minpT default to 0.0) no8:(optional, if efficiency range is different from etamatchrange) no9:50(optional skipping first xx files)
#./runmc.sh MCE211203.1 1.5 0.3 HITight False mc
#echo $1
linenumber=0
while IFS= read -r line; do
	echo $linenumber
	b=${line#*$6}
	c=${b%%.*}    #data campaign
	d=${line##*.} #production tag

	if [ "$7" = "" ]; then
		ptCut=0.0
	else
		ptCut=$7
	fi

	if [ "$5" = "True" ] && [ "$8" != "" ]; then
		eta=$8
	else
		eta=$2
	fi

	if [ "${6}" = "mc" ]; then
		if [ "$c" = "15_5TeV" ]; then
			runNum=226000
		fi
		if [ "$c" = "16_5TeV" ]; then
			runNum=313000
		fi
	fi
	if [ "$6" = "data" ]; then
		temp=${b#*.}
		runNum=${temp%%.*}
		runNum=$(expr $runNum + 0)
	fi
	#echo $c
	echo $runNum
	echo $line
	#~/getflow/GetPHYSHI_single.sh $line $c $d
	echo 'eta match range: '$5
	echo 'eta eff range: '$eta
	echo 'pT cut: '$ptCut
	co=$c'_'$d
	echo $co

	cp ~/getflow/condors/run_temp.job ~/getflow/condors/runmc_$co_$1_$2_$3_$4_$5.job
	sed -i "s@^Executable.*@Executable   = /usatlas/u/cher97/getflow/runmcloop.sh@" ~/getflow/condors/runmc_$co_$1_$2_$3_$4_$5.job
	sed -i "s@^Arguments.*@Arguments       = $1 _pnfs $co \$(Process) $2 $3 $4 $5 $runNum $ptCut $eta $8@" ~/getflow/condors/runmc_$co_$1_$2_$3_$4_$5.job
	nof=$(wc -l <~/getflow/txts/$co\_root_pnfs.txt)
	#nof=1
	sed -i "s@^Queue.*@Queue $nof@" ~/getflow/condors/runmc_$co_$1_$2_$3_$4_$5.job
	#cat run_PC$c.job
	exec 0<&1

	while true; do
		read -p "Do you wish to remove old folder and rerun? (y/n) " answer
		if [[ $answer =~ ^[Yy]$ ]]; then
			echo "deleting original run folder"
			rm -rf /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$co'_MCEff_'$2_$3_$4_$5/
		else
			echo "writing to old folder"
		fi
		break
	done

	mkdir -p /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$co'_MCEff_'$2_$3_$4_$5/
	echo $1_pnfs_$co'_MCEff_'$2_$3_$4_$5
	#cat ~/getflow/condors/runmc_$co_$1_$2_$3_$4.job
	#condor_submit ~/getflow/condors/runmc_$co_$1_$2_$3_$4_$5.job
	linenumber=$((linenumber + 1))
	echo $linenumber
done <$input
