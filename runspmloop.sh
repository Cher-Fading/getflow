#!/bin/bash
#input="/atlasgpfs01/usatlas/data/cher97/mc16_5TeV.txt"
# ./runsploop.sh Qmean210916.1 _pnfs 365678 PC 3 True 0.5

input=~/getflow/txts/$3_$4_root$2.txt
#input="mc16_5TeV_short.txt"
#mkdir -p '/usatlas/scratch/cher97/'$1$2_$3_$4

#indexline=$1
linenumber=0
while IFS= read -r line; do
	if [ $6 -eq $linenumber ]; then
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
		cp /usatlas/u/cher97/flow/source/MyAnalysis/share/ATestRun_eljob.py $tempdir/'tempout'$3_$4$linenumber/
		chmod +x $tempdir/'tempout'$3_$4$linenumber/ATestRun_eljob.py
		sed -i "s@^inputFilePath = .*@inputFilePath = '$tempdir/tempin$3_$4$linenumber'@" $tempdir/'tempout'$3_$4$linenumber/ATestRun_eljob.py
		sed -i "s@^ROOT.SH.ScanDir().filePattern(.*@ROOT.SH.ScanDir().filePattern( '$filename').scan( sh, inputFilePath )@" $tempdir/'tempout'$4_$5$linenumber/ATestRun_eljob.py
		sed -i "s@.*alg.jumpLow.*@alg.jumpLow = $6@" $tempdir/'tempout'$3_$4$linenumber/ATestRun_eljob.py
		sed -i "s@.*alg.jumpBar.*@alg.jumpBar = $7@" $tempdir/'tempout'$3_$4$linenumber/ATestRun_eljob.py
		#echo $PWD
		$tempdir/'tempout'$3_$4$linenumber/ATestRun_eljob.py --submission-dir=submitDir
		cp $tempdir/tempout$3_$4$linenumber/submitDir/data-myOutput/*.root /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$c'_CC_qmean_'$6_$7/qmean$3_$4_$linenumber'.root'
		sleep 2
		#rm -rf $tempdir/tempin$3_$4$linenumber
		#rm -rf $tempdir/tempout$3_$4$linenumber
		#rm -rf $tempdir
	fi
	linenumber=$((linenumber + 1))
done <$input
