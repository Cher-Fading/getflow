#!/bin/bash

input=~/getflow/txts/$3runall_runlist.txt

#./runmc.sh no1:location no2:MCE211203.1 no3:mc18jet no4:optional,skip first n
#copy and open to be edited steering macro
cp ~/$1/source/MyAnalysis/share/ATestRun_eljob.py ~/getflow/py/ATestRun_eljob$1_$2_$3.py
emacs ~/getflow/py/ATestRun_eljob$1_$2_$3.py
template=$1_$2_$3
linenumber=1
if [ "$4" = "" ]; then
skip=0
else
skip=$4
fi

while IFS= read -r line <&3; do
	echo 'line_'${bold}$linenumber${normal}'-------------------------------------------------------------'
folder=$1_$2_$3_$linenumber

	if [ "$line" = "" ]; then
		break
	fi

	cp ~/getflow/condors/run_temp.job ~/getflow/condors/runall_$folder.job

	sed -i "s@^Executable.*@Executable   = /usatlas/u/cher97/getflow/runallloop.sh@" ~/getflow/condors/runall_$folder.job
	sed -i "s@^Arguments.*@Arguments       = \$(Process) $folder $line $skip $template@" ~/getflow/condors/runall_$folder.job
	nofful=$(wc -l <~/getflow/txts/$line.txt)
	nof=$nofful
	#nof=$((nofful/4))
	sed -i "s@^Queue.*@Queue $nof@" ~/getflow/condors/runall_$folder.job


	#exec 0<&1

	read -p "Do you wish to remove old folder and rerun? (y/n) " answer
	if [[ $answer =~ ^[Yy]$ ]]; then
		echo "deleting original run folder"
		rm -rf /atlasgpfs01/usatlas/data/cher97/$folder/
	else
		echo "writing to old folder"
	fi

	mkdir -p /atlasgpfs01/usatlas/data/cher97/$folder/

	#cat ~/getflow/condors/runmc_$co_$1_$6_$2_$3_$4_$5.job
	condor_submit ~/getflow/condors/runall_$folder.job
	linenumber=$((linenumber + 1))
done 3<$input
