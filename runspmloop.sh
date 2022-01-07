#!/bin/bash
#input="/atlasgpfs01/usatlas/data/cher97/mc16_5TeV.txt"
# ./runspmloop.sh SPMethod211201.1 _pnfs 365678 k1029_m2048 PC 3 20


input=~/getflow/txts/$3_$5_root$2.txt
#input="mc16_5TeV_short.txt"
mkdir -p /atlasgpfs01/usatlas/data/cher97/$1_pnfs_$3_$5_spmethod

#indexline=$1
linenumber=0
while IFS= read -r line; do
	if [ $6 -eq $linenumber ]; then
		tempdir=$(mktemp -d)
		cd $tempdir
		echo $tempdir
		mkdir $tempdir/'tempin'$3_$5$6$linenumber
		xrdcp 'root://dcgftp.usatlas.bnl.gov:1096/'$line $tempdir/'tempin'$3_$5$6$linenumber
		cd $tempdir/'tempin'$3_$5$6$linenumber
		filename=$(ls *.root*)
		echo $filename
		mkdir $tempdir/'tempout'$3_$5$6$linenumber
		cd $tempdir/'tempout'$3_$5$6$linenumber
		for ((i = 0; i < $7; i++)); do
			cp /usatlas/u/cher97/spmethod/source/MyAnalysis/share/ATestRun_eljob.py $tempdir/'tempout'$3_$5$6$linenumber/ATestRun_eljob$i.py
			echo $(ls)
			chmod +x $tempdir/'tempout'$3_$5$6$linenumber/ATestRun_eljob$i.py
			sed -i "s@^inputFilePath = .*@inputFilePath = '$tempdir/tempin$3_$5$6$linenumber'@" $tempdir/'tempout'$3_$5$6$linenumber/ATestRun_eljob$i.py
			sed -i "s@^ROOT.SH.ScanDir().filePattern(.*@ROOT.SH.ScanDir().filePattern( '$filename').scan( sh, inputFilePath )@" $tempdir/'tempout'$3_$5$6$linenumber/ATestRun_eljob$i.py
			#sed -i "s@.*alg.recenter.*@alg.recenter = $6@" $tempdir/'tempout'$3_$5$linenumber/ATestRun_eljob.py
			#sed -i "s@.*alg.overflow.*@alg.overflow = $7@" $tempdir/'tempout'$3_$5$linenumber/ATestRun_eljob.py
			sed -i "s@.*alg.RunNum.*@alg.RunNum = $3@" $tempdir/'tempout'$3_$5$6$linenumber/ATestRun_eljob$i.py
			sed -i "s@.*alg.QCal_name.*@alg.QCal_name = \'MyAnalysis\/qmean\.1026-1\.$3\.$4\.tot\.root\'@" $tempdir/'tempout'$3_$5$6$linenumber/ATestRun_eljob$i.py
			sed -i "s@.*alg.Rem.*@alg.Rem = $i@" $tempdir/'tempout'$3_$5$6$linenumber/ATestRun_eljob$i.py
			sed -i "s@.*alg.numSubs.*@alg.numSubs = $7@" $tempdir/'tempout'$3_$5$6$linenumber/ATestRun_eljob$i.py
			cat $tempdir/'tempout'$3_$5$6$linenumber/ATestRun_eljob$i.py
			$tempdir/'tempout'$3_$5$6$linenumber/ATestRun_eljob$i.py --submission-dir=submitDir$i
			ls $tempdir/tempout$3_$5$6$linenumber/submitDir$i/data-myOutput/*.root 
			cp $tempdir/tempout$3_$5$6$linenumber/submitDir$i/data-myOutput/*.root /atlasgpfs01/usatlas/data/cher97/$1$2_$3_$4_$5'_spmethod_sub'$7/sub$i/spmethod$3_$5_$6_$linenumber_$i'.root'
			sleep 2
			#rm -rf $tempdir/tempin$3_$5$linenumber
			#rm -rf $tempdir/tempout$3_$5$linenumber
			#rm -rf $tempdir
		done
	fi
	linenumber=$((linenumber + 1))
done <$input
