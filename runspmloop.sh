#!/bin/bash
#input="/atlasgpfs01/usatlas/data/cher97/mc16_5TeV.txt"
# ./runspmloop.sh SPMethod211007.1 _pnfs 365678 PC 3 True

input=~/getflow/txts/$3_$4_root$2.txt
#input="mc16_5TeV_short.txt"
mkdir -p /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$3_$4_spmethod_$6_$7

#indexline=$1
linenumber=0
while IFS= read -r line; do
	if [ $5 -eq $linenumber ]; then
		tempdir=$(mktemp -d)
		cd $tempdir
		echo $tempdir
		mkdir $tempdir/'tempin'$3_$4$linenumber
		xrdcp 'root://dcgftp.usatlas.bnl.gov:1096/'$line $tempdir/'tempin'$3_$4$linenumber
		cd $tempdir/'tempin'$3_$4$linenumber
		filename=$(ls *.root*)
		echo $filename
		mkdir $tempdir/'tempout'$3_$4$linenumber
		cd $tempdir/'tempout'$3_$4$linenumber
		cp /usatlas/u/cher97/spmethod/source/MyAnalysis/share/ATestRun_eljob.py $tempdir/'tempout'$3_$4$linenumber/
		echo $(ls)
		chmod +x $tempdir/'tempout'$3_$4$linenumber/ATestRun_eljob.py
		sed -i "s@^inputFilePath = .*@inputFilePath = '$tempdir/tempin$3_$4$linenumber'@" $tempdir/'tempout'$3_$4$linenumber/ATestRun_eljob.py
		sed -i "s@^ROOT.SH.ScanDir().filePattern(.*@ROOT.SH.ScanDir().filePattern( '$filename').scan( sh, inputFilePath )@" $tempdir/'tempout'$3_$4$linenumber/ATestRun_eljob.py
		sed -i "s@.*alg.recenter.*@alg.recenter = $6@" $tempdir/'tempout'$3_$4$linenumber/ATestRun_eljob.py
		#sed -i "s@.*alg.overflow.*@alg.overflow = $7@" $tempdir/'tempout'$3_$4$linenumber/ATestRun_eljob.py
		cat $tempdir/'tempout'$3_$4$linenumber/ATestRun_eljob.py
		$tempdir/'tempout'$3_$4$linenumber/ATestRun_eljob.py --submission-dir=submitDir
		ls $tempdir/tempout$3_$4$linenumber/submitDir/data-myOutput/*.root
		cp $tempdir/tempout$3_$4$linenumber/submitDir/data-myOutput/*.root /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$3_$4_spmethod_$6_$7/spmethod$3_$4_$linenumber'.root'
		sleep 2
		rm -rf $tempdir/tempin$3_$4$linenumber
		rm -rf $tempdir/tempout$3_$4$linenumber
		rm -rf $tempdir
	fi
	linenumber=$((linenumber + 1))
done <$input
