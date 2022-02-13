#!/bin/bash
#input="/atlasgpfs01/usatlas/data/cher97/mc16_5TeV.txt"
# ./runmcloop.sh no1:(code version)MCE211214.1 no2:(localtion)_pnfs no3:(dataset)15_5TeV_e4962_a868_s2921_r9447 no4:(linenumber)5 no5:(etarange)1.0 no6:(matchprob)0.3 no7:(track cut)HITight no8:(doeff)False no9:($runnum)313000 no10:(ptcut)0.5 no11:(eta eff range)2.5 no12:isMC no13:1.0 (truthptcut) no14: AOD no15:(optional skip)0

# MCE220119.3 _pnfs 18_hi_365678_k1029_m2048 200 1.5 0.3 HITight True 365678 0.0 1.5 True 50

input=~/getflow/txts/$3_root$2.txt
#input="mc16_5TeV_short.txt"
mkdir -p /atlasgpfs01/usatlas/data/cher97/$1$2_$3'_MCEff_'$5_$6_$7_$8

#indexline=$1
linenumber=0
offset=${15}
while IFS= read -r line; do
	if [ $4 -eq $((linenumber-offset)) ]; then
		tempdir=$(mktemp -d)
		cd $tempdir
		echo $tempdir
		mkdir $tempdir/'tempin'$3_$linenumber
		xrdcp 'root://dcgftp.usatlas.bnl.gov:1096/'$line $tempdir/'tempin'$3_$linenumber
		cd $tempdir/'tempin'$3_$linenumber
		filename=$(ls *.root*)
		echo $filename
		mkdir $tempdir/'tempout'$3_$linenumber
		cd $tempdir/'tempout'$3_$linenumber
		cp /usatlas/u/cher97/mceff/source/MyAnalysis/share/ATestRun_eljob.py $tempdir/'tempout'$3_$linenumber/
		chmod +x $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py
		sed -i "s@^inputFilePath = .*@inputFilePath = '$tempdir/tempin$3_$linenumber'@" $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py
		sed -i "s@^ROOT.SH.ScanDir().filePattern(.*@ROOT.SH.ScanDir().filePattern( '$filename').scan( sh, inputFilePath )@" $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py
		sed -i "s@.*alg.RefEta.*@alg.RefEta = ${11}@" $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py
sed -i "s@.*alg.isMC.*@alg.isMC = ${12}@" $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py
		sed -i "s@.*alg.EtaMatchRange.*@alg.EtaMatchRange = $5@" $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py
		sed -i "s@.*alg.ProbLim.*@alg.ProbLim = $6@" $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py
                sed -i "s@.*alg.CutLevel.*@alg.CutLevel = \"$7\"@" $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py
                sed -i "s@.*alg.Eff.*@alg.Eff = $8@" $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py
		sed -i "s@.*alg.runNum.*@alg.runNum = $9@" $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py
sed -i "s@.*alg.FileName.*@alg.FileName = \"mce_$4_$linenumber\"@" $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py
sed -i "s@.*alg.PtCut =.*@alg.PtCut = ${10}@" $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py
sed -i "s@.*alg.PtCutTruth.*@alg.PtCutTruth = ${13}@" $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py
sed -i "s@^ROOT.SH.ScanDir().filePattern.*@ROOT.SH.ScanDir().filePattern( \'\*${14}\*\').scan( sh, inputFilePath )@" $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py
		#echo $PWD
		$tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py --submission-dir=submitDir
		cp $tempdir/tempout$3_$linenumber/submitDir/data-myOutput/*.root /atlasgpfs01/usatlas/data/cher97/$1$2_$3'_MCEff_'$5_$6_$7_$8/mce_$4_$linenumber'.root'
cp $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py /atlasgpfs01/usatlas/data/cher97/$1$2_$3'_MCEff_'$5_$6_$7_$8/mce_$4_$linenumber'ATestRun_eljob.py'
cp $tempdir/'tempout'$3_$linenumber/mce_$4_$linenumber'.txt' /atlasgpfs01/usatlas/data/cher97/$1$2_$3'_MCEff_'$5_$6_$7_$8/mce_$4_$linenumber'.txt'
		sleep 2
		rm -rf $tempdir/tempin$3_$linenumber
		rm -rf $tempdir/tempout$3_$linenumber
		rm -rf $tempdir
	fi
	linenumber=$((linenumber + 1))
done <$input
