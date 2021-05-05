#!/bin/bash
#input="/atlasgpfs01/usatlas/data/cher97/mc16_5TeV.txt"
# ./run.sh Flow210504.1 _pnfs 365678 PC 3

input="../getflow/$3_$4_root$2.txt"
#input="mc16_5TeV_short.txt"

mkdir -p /usatlas/scratch/cher97/$1$2_$3_$4_$5

#indexline=$1
linenumber=0
while IFS= read -r line; do
	if [ $5 -eq $linenumber ]; then
		mkdir -p '/usatlas/scratch/cher97/tempin'$3_$linenumber
		#xrdcp 'root://dcgftp.usatlas.bnl.gov:1096/'$line '/usatlas/scratch/cher97/tempin'$3_$linenumber		
		filename=$(ls /usatlas/scratch/cher97/tempin$3_$linenumber)
		cp /usatlas/u/cher97/flow/sources/MyAnalysis/share/ATestRun_eljob.py /usatlas/scratch/cher97/tempin$3_$linenumber/
		chmod +X /usatlas/scratch/cher97/tempin$3_$linenumber/ATestRun_eljob.py
		sed -i "s@^inputFilePath = .*@inputFilePath = '/usatlas/scratch/cher97/tempin$3_$linenumber'@" /usatlas/scratch/cher97/tempin$3_$linenumber/ATestRun_eljob.py
    	sed -i "s/^ROOT.SH.ScanDir().filePattern(.*/ROOT.SH.ScanDir().filePattern( '$filename').scan( sh, inputFilePath )/" /usatlas/scratch/cher97/tempin$3_$linenumber/ATestRun_eljob.py
		cat /usatlas/scratch/cher97/tempin$3_$linenumber/ATestRun_eljob.py
		sleep 2
		#rm -rf '/usatlas/scratch/cher97/tempin'$3_$linenumber
	fi
	linenumber=$((linenumber + 1))
done <"$input"

