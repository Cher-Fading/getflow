#!/bin/bash
#input="/atlasgpfs01/usatlas/data/cher97/mc16_5TeV.txt"
# ./runallloop.sh no1 process no2 foldername no3 inputtxt no4 skipn no5:template

input=~/getflow/txts/$3.txt
#input="mc16_5TeV_short.txt"
mkdir -p /atlasgpfs01/usatlas/data/cher97/$2

#indexline=$1
linenumber=0
offset=${4}
echo $offset
while IFS= read -r line; do
	if [ $1 -eq $((linenumber - offset)) ]; then
echo $line
		tempdir=$(mktemp -d)
		cd $tempdir
		echo $tempdir
		mkdir $tempdir/'tempin'$2_$linenumber
		xrdcp 'root://dcgftp.usatlas.bnl.gov:1096/'$line $tempdir/'tempin'$2_$linenumber
		cd $tempdir/'tempin'$2_$linenumber
		filename=$(ls *.root*)
		echo $filename
		mkdir $tempdir/'tempout'$2_$linenumber
		cd $tempdir/'tempout'$2_$linenumber
		cp /usatlas/u/cher97/getflow/py/ATestRun_eljob$template.py $tempdir/'tempout'$2_$linenumber/
		chmod +x $tempdir/'tempout'$2_$linenumber/ATestRun_eljob.py
		sed -i "s@^inputFilePath = .*@inputFilePath = '$tempdir/tempin$2_$linenumber'@" $tempdir/'tempout'$2_$linenumber/ATestRun_eljob.py
		sed -i "s@^ROOT.SH.ScanDir().filePattern(.*@ROOT.SH.ScanDir().filePattern( '$filename').scan( sh, inputFilePath )@" $tempdir/'tempout'$2_$linenumber/ATestRun_eljob.py
		sed -i "s@.*alg.FileName.*@alg.FileName = \"mce_$1_$linenumber\"@" $tempdir/'tempout'$2_$linenumber/ATestRun_eljob.py
		JZ=-1
	if [[ "$6" = *"mc"*"jet"* ]]; then
		tmps=${line#*JZ}
		JZ=${tmps:0:1}
sed -i "s@.*alg.JZ.*@alg.JZ = $JZ@" $tempdir/'tempout'$2_$linenumber/ATestRun_eljob.py
	fi
		#echo $PWD
		$tempdir/'tempout'$2_$linenumber/ATestRun_eljob.py --submission-dir=submitDir
		cp $tempdir/tempout$2_$linenumber/submitDir/data-myOutput/*.root /atlasgpfs01/usatlas/data/cher97/$2/mce_$1_$linenumber'.root'
		cp $tempdir/'tempout'$2_$linenumber/ATestRun_eljob.py /atlasgpfs01/usatlas/data/cher97/$2/mce_$1_$linenumber'ATestRun_eljob.py'
		cp $tempdir/'tempout'$2_$linenumber/mce_$1_$linenumber'.txt' /atlasgpfs01/usatlas/data/cher97/$2/mce_$1_$linenumber'.txt'
		sleep 2
		rm -rf $tempdir/tempin$2_$linenumber
		rm -rf $tempdir/tempout$2_$linenumber
		rm -rf $tempdir
	fi
	linenumber=$((linenumber + 1))
done <$input
