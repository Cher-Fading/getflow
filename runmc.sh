#!/bin/bash

input=~/getflow/txts/$1_runlist.txt
#cat $input
#cat ~/getflow/$1_runlist.txt
#./runmc.sh no1:MCE211203.1 no2:1.5(etarange) no3:0.3(min prob) no4:HITight no5:False(do eff) no6:mc no7:0.5(optional minpT default to 0.0) no8:(optional, if efficiency range is different from etamatchrange) no9:1.0 (optional, truthptcut, default to 1.0) no10: AOD (optional file type, default to AOD) no11: 0 (optional minimum primary vertices, default to 0) no12:50(optional skipping first xx files)
#./runmc.sh MCE211203.1 1.5 0.3 HITight False mc 0.0 2.5 0.5 AOD
#echo $1

linenumber=0
bold=$(tput bold)
normal=$(tput sgr0)
>~/getflow/txts/$1_log.txt

while IFS= read -r line <&3; do
	echo 'line_'${bold}$linenumber${normal}'-------------------------------------------------------------'
	echo 'line_'$linenumber'-------------------------------------------------------------' >>~/getflow/txts/$1_log.txt

	if [ "$line" = "" ]; then
		break
	fi
	b=${line#*$6}
	c=${b%%.*}    #data campaign
	d=${line##*.} #production tag

	if [ "$7" = "" ]; then
		ptCut=0.0
	else
		ptCut=$7
	fi

	if [ "$9" = "" ]; then
		ptTruthCut=1.0
	else
		ptTruthCut=$9
	fi

	if [ "${10}" = "" ]; then
		dataset=AOD
	else
		dataset=${10}
	fi

	if [ "${11}" = "" ]; then
		primlim=0
	else
		primlim=${11}
	fi

	if [ "$5" = "True" ] && [ "$8" != "" ]; then
		eta=$8
	else
		eta=$2
	fi

	if [ "${6}" = "mc" ]; then
		isMC=True
		if [ "$c" = "15_5TeV" ]; then
			runNum=226000
		fi
		if [ "$c" = "16_5TeV" ]; then
			runNum=313000
		fi
	fi
	if [ "$6" = "data" ]; then
		isMC=False
		temp=${b#*.}
		runNum=${temp%%.*}
		runNum=$(expr $runNum + 0)
		#echo $c
		c=$c'_'$runNum
	fi
	echo ${bold}Dataset:${normal}' '$line
	echo ${bold}Specs:${normal}-------------------------------------------------------------
	#~/getflow/GetPHYSHI_single.sh $line $c $d
	#echo $c
	echo ${bold}run number:${normal}' '$runNum
	echo ${bold}eta match range:${normal}' '$2
	echo ${bold}eta eff range:${normal}' '$eta
	echo ${bold}pT cut:${normal}' '$ptCut
	echo ${bold}pT Truth cut:${normal}' '$ptTruthCut
	echo ${bold}data type:${normal}' '$dataset

	echo 'Dataset: '$line >>~/getflow/txts/$1_log.txt
	echo Specs:------------------------------------------------------------- >>~/getflow/txts/$1_log.txt
	#~/getflow/GetPHYSHI_single.sh $line $c $d
	#echo $c
	echo 'run number: '$runNum >>~/getflow/txts/$1_log.txt
	echo 'eta match range: '$2 >>~/getflow/txts/$1_log.txt
	echo 'eta eff range: '$eta >>~/getflow/txts/$1_log.txt
	echo 'pT cut: '$ptCut >>~/getflow/txts/$1_log.txt
	echo 'pT Truth cut: '$ptTruthCut >>~/getflow/txts/$1_log.txt
	echo 'data type: '$dataset >>~/getflow/txts/$1_log.txt
	co=$c'_'$d
	#echo $co

	cp ~/getflow/condors/run_temp.job ~/getflow/condors/runmc_$co_$1_$2_$3_$4_$5.job

	sed -i "s@^Executable.*@Executable   = /usatlas/u/cher97/getflow/runmcloop.sh@" ~/getflow/condors/runmc_$co_$1_$2_$3_$4_$5.job
	sed -i "s@^Arguments.*@Arguments       = $1 _pnfs $co \$(Process) $2 $3 $4 $5 $runNum $ptCut $eta $isMC $ptTruthCut $dataset $primlim ${12}@" ~/getflow/condors/runmc_$co_$1_$2_$3_$4_$5.job
	nof=$(wc -l <~/getflow/txts/$co\_root_pnfs.txt)
	#nof=50
	sed -i "s@^Queue.*@Queue $nof@" ~/getflow/condors/runmc_$co_$1_$2_$3_$4_$5.job
	#cat run_PC$c.job
	echo '-------------------------------------------------------------------'
	echo '-------------------------------------------------------------------' >>~/getflow/txts/$1_log.txt

	#exec 0<&1

	read -p "Do you wish to remove old folder and rerun? (y/n) " answer
	if [[ $answer =~ ^[Yy]$ ]]; then
		echo "deleting original run folder"
		rm -rf /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$co'_MCEff_'$2_$3_$4_$5/
	else
		echo "writing to old folder"
	fi

	mkdir -p /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$co'_MCEff_'$2_$3_$4_$5/
	echo $1_pnfs_$co'_MCEff_'$2_$3_$4_$5
	echo $1_pnfs_$co'_MCEff_'$2_$3_$4_$5 >>~/getflow/txts/$1_log.txt
	#cat ~/getflow/condors/runmc_$co_$1_$2_$3_$4_$5.job
	condor_submit ~/getflow/condors/runmc_$co_$1_$2_$3_$4_$5.job
	linenumber=$((linenumber + 1))
	echo 'line_-------------------------------------------------------------' >>~/getflow/txts/$1_log.txt
	echo 'line_'${bold}$linenumber${normal}'-------------------------------------------------------------'
done 3<$input
