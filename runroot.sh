#!/bin/bash
#./runroot.sh /usatlas/u/cher97/mceff/PbPb.C data18jetntuples version
input=~/getflow/txts/$2.txt

full=$1
exec=${full##*/}
echo $exec
func=${exec%.*}
echo $func
#emacs $1

echo $full
path=${full%/*}
echo $path
cd $path
git tag -a $3 -m "version $3"
git push --tags

outputfolder=/atlasgpfs01/usatlas/data/cher97/$2$3$exec

read -p "Do you wish to remove old folder and rerun? (y/n) " answer
	if [[ $answer =~ ^[Yy]$ ]]; then
		echo "deleting original run folder"
		rm -rf $outputfolder
	else
		echo "writing to old folder"
	fi

mkdir -p $outputfolder
cp $1 $outputfolder/$2$3$exec

sed -i "s/void $func(/void $2$3$func(/" $outputfolder/$2$3$exec

linenumber=0
cp ~/getflow/condors/run_temp.job ~/getflow/condors/runroot$exec$2$3.job
sed -i "s@^Executable.*@Executable   = /usatlas/u/cher97/getflow/runrootloop.sh@" ~/getflow/condors/runroot$exec$2$3.job
sed -i "s@^Arguments.*@Arguments       = \$(Process) $outputfolder/$2$3$exec $2 $outputfolder@" ~/getflow/condors/runroot$exec$2$3.job
nof=$(wc -l <~/getflow/txts/$2'.txt')
sed -i "s@^Queue.*@Queue $nof@" ~/getflow/condors/runroot$exec$2$3.job
#cat ~/getflow/condors/runroot$exec$2$3.job
condor_submit ~/getflow/condors/runroot$exec$2$3.job
