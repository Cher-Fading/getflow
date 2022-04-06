#!/bin/bash

input=~/getflow/txts/$6_runlist.txt
#cat $input
#cat ~/getflow/$1_runlist.txt
#./runmc.sh no1:MCE211203.1 no2:1.5(etarange) no3:0.3(min prob) no4:HITight no5:False(do eff) no6:mc no7:0.5(min match pT, default to 0.5) no8:(optional eta mult reco range, default 2.5) no9:1.0 (optional, multptcut, default to 1.0) no10:(optional eta mult truth range, default 2.5) no11:1.0 (optional, truthpt mult, default to 1.0) no12: 0 (optional minimum primary vertices, default to 0) no13:(optional, centrality choice, default to fcal (1)) no14:50(optional skipping first xx files)
#./runmc.sh MCE220329.1 2.5 0.3 HITight True mc18jet
#echo $1

linenumber=0
bold=$(tput bold)
normal=$(tput sgr0)
>~/getflow/txts/$1_$6_log.txt

while IFS= read -r line <&3; do
	echo 'line_'${bold}$linenumber${normal}'-------------------------------------------------------------'
	echo 'line_'$linenumber'-------------------------------------------------------------' >>~/getflow/txts/$1_$6_log.txt

	if [ "$line" = "" ]; then
		break
	fi
	if [[ "$6" = *"mc"* ]]; then
	b=${line#*mc}
	echo $b
	fi
	if [[ "$6" = *"data"* ]]; then
	b=${line#*data}
	fi
	c=${b%%.*}    #data campaign
	d=${line##*.} #production tag

	if [ "$7" = "" ]; then
		ptCut=0.5
	else
		ptCut=$7
	fi
	if [ "$8" = "" ]; then
		etaMult=2.5
	else
		etaMult=$8
	fi

	if [ "$9" = "" ]; then
		ptMult=1.0
	else
		ptMult=$9
	fi

	if [ "${10}" = "" ]; then
		etaTruthMult=2.5
	else
		etaTruthMult=${10}
	fi

	if [ "${11}" = "" ]; then
		ptTruthMult=1.0
	else
		ptTruthMult=${11}
	fi

	if [ "${12}" = "" ]; then
		primlim=0
	else
		primlim=${12}
	fi
	if [ "${13}" = "" ]; then
		cent=1
	else
		cent=${13}
	fi

	if [[ "${6}" = *"mc"* ]]; then
		isMC=True
		if [ "$c" = "15_5TeV" ]; then
			runNum=226000
		fi
		if [ "$c" = "16_5TeV" ]; then
			runNum=313000
		fi
	fi
	if [[ "$6" = *"data"* ]]; then
		isMC=False
		temp=${b#*.}
		runNum=${temp%%.*}
		runNum=$(expr $runNum + 0)
		#echo $c
		c=$c'_'$runNum
	fi
	hasjets=False
	if [[ "$6" = *"jet"* ]]; then
		hasjets=True
	fi
	JZ=-1
	if [[ "$6" = *"mc"*"jet"* ]]; then
		tmps=${line#*JZ}
		JZ=${tmps:0:1}
	fi

	echo ${bold}Dataset:${normal}' '$line
	echo ${bold}Specs:${normal}-------------------------------------------------------------
	#~/getflow/GetPHYSHI_single.sh $line $c $d
	#echo $c
	echo ${bold}run number:${normal}' '$runNum
	echo ${bold}eta match range:${normal}' '$2
	echo ${bold}pt match min:${normal}' '$ptCut
	echo ${bold}eta multiplicity count range:${normal}' '$etaMult
	echo ${bold}pT multiplicity count range:${normal}' '$ptMult
	echo ${bold}pT Truth multiplicity count range:${normal}' '$ptTruthMult
	echo ${bold}eta Truth multiplicity count range:${normal}' '$etaTruthMult
	echo ${bold}minimum primary:${normal}' '$primlim
	echo ${bold}Centrality Selection:${normal}' '$cent
	echo ${bold}HasJets?${normal}' '$hasjets
	echo ${bold}JZ:${normal}' '$JZ

	echo 'Dataset: '$line >>~/getflow/txts/$1_$6_log.txt
	echo Specs:------------------------------------------------------------- >>~/getflow/txts/$1_$6_log.txt
	#~/getflow/GetPHYSHI_single.sh $line $c $d
	#echo $c
	echo 'run number: '$runNum >>~/getflow/txts/$1_$6_log.txt
	echo 'eta match range: '$2 >>~/getflow/txts/$1_$6_log.txt
	echo 'pt match min: '$ptCut >>~/getflow/txts/$1_$6_log.txt
	echo 'eta multiplicity count range '$etaMult >>~/getflow/txts/$1_$6_log.txt
	echo 'pT multiplicity count range: '$ptMult >>~/getflow/txts/$1_$6_log.txt
	echo 'pT Truth multiplicity count range: '$ptTruthMult >>~/getflow/txts/$1_$6_log.txt
	echo 'eta Truth multiplicity count range: '$etaTruthMult >>~/getflow/txts/$1_$6_log.txt
	echo 'minimum primary: '$primlim >>~/getflow/txts/$1_$6_log.txt
	echo 'Centrality Selection: '$cent >>~/getflow/txts/$1_$6_log.txt
	echo 'HasJets? '$hasjets >>~/getflow/txts/$1_$6_log.txt
	echo 'JZ: '$JZ >>~/getflow/txts/$1_$6_log.txt
	co=$c'_'$d
	echo $co

	cp ~/getflow/condors/run_temp.job ~/getflow/condors/runmc_$co_$1_$6_$2_$3_$4_$5.job

	sed -i "s@^Executable.*@Executable   = /usatlas/u/cher97/getflow/runmcloop.sh@" ~/getflow/condors/runmc_$co_$1_$6_$2_$3_$4_$5.job
	sed -i "s@^Arguments.*@Arguments       = $1_$6 _pnfs $co \$(Process) $2 $3 $4 $5 $runNum $isMC $ptCut $ptMult $etaMult $ptTruthMult $etaTruthMult $primlim $cent $hasjets $JZ ${14}@" ~/getflow/condors/runmc_$co_$1_$6_$2_$3_$4_$5.job
	nofful=$(wc -l <~/getflow/txts/$co\_root_pnfs.txt)
	nof=$nofful
	#nof=$((nofful/4))
	nof=$nofful
	sed -i "s@^Queue.*@Queue $nof@" ~/getflow/condors/runmc_$co_$1_$6_$2_$3_$4_$5.job
	#cat run_PC$c.job
	echo '-------------------------------------------------------------------'
	echo '-------------------------------------------------------------------' >>~/getflow/txts/$1_$6_log.txt

	#exec 0<&1

	read -p "Do you wish to remove old folder and rerun? (y/n) " answer
	if [[ $answer =~ ^[Yy]$ ]]; then
		echo "deleting original run folder"
		rm -rf /atlasgpfs01/usatlas/data/cher97/$1_$6_pnfs_$co'_MCEff_'$2_$3_$4_$5/
	else
		echo "writing to old folder"
	fi

	mkdir -p /atlasgpfs01/usatlas/data/cher97/$1_$6_pnfs_$co'_MCEff_'$2_$3_$4_$5/
	echo $1_$6_pnfs_$co'_MCEff_'$2_$3_$4_$5
	echo $1_$6_pnfs_$co'_MCEff_'$2_$3_$4_$5 >>~/getflow/txts/$1_$6_log.txt
	#cat ~/getflow/condors/runmc_$co_$1_$6_$2_$3_$4_$5.job
	condor_submit ~/getflow/condors/runmc_$co_$1_$6_$2_$3_$4_$5.job
	linenumber=$((linenumber + 1))
	echo 'line_-------------------------------------------------------------' >>~/getflow/txts/$1_$6_log.txt
	echo 'line_'${bold}$linenumber${normal}'-------------------------------------------------------------'
done 3<$input
