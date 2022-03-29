#!/bin/bash
#input="/atlasgpfs01/usatlas/data/cher97/mc16_5TeV.txt"
# ./runmcloop.sh no1:(code version+data)MCE211214.1 no2:(location)_pnfs no3:(dataset)15_5TeV_e4962_a868_s2921_r9447 no4:(linenumber)5 no5:(etamatchrange)1.5 no6:(matchprob)0.3 no7:(track cut)HITight no8:(doeff)False no9:($runnum)313000 no10:isMC no11:(ptcut for matching)0.5 no12:(ptcut for multilicity)1.0 no13:(eta mult range)2.5 no14:1.0 (truth pt multrange) no15:2.5 (truth eta multrange) no16: min prim vertex 0 no17: cent no18:hasjets no19:JZ no20:(optional skip)0
#./runmcloop.sh MCE220310.1 _pnfs 15_5TeV_e4962_a868_s2921_r9447 5 1.5 0.3 HITight True 226000 True 0.5 1.0 2.5 1.0 2.5 0 1 True 1

input=~/getflow/txts/$3_root$2.txt
#input="mc16_5TeV_short.txt"
mkdir -p /atlasgpfs01/usatlas/data/cher97/$1$2_$3'_MCEff_'$5_$6_$7_$8

#indexline=$1
linenumber=0
offset=${20}
echo $offset
while IFS= read -r line; do
	if [ $4 -eq $((linenumber - offset)) ]; then
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
		sed -i "s@.*alg.isMC.*@alg.isMC = ${10}@" $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py

		sed -i "s@.*alg.EtaMatch.*@alg.EtaMatch = ${5}@" $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py
		sed -i "s@.*alg.PtCutMatch.*@alg.PtCutMatch = ${11}@" $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py

		sed -i "s@.*alg.ProbLim.*@alg.ProbLim = $6@" $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py
		sed -i "s@.*alg.CutLevel.*@alg.CutLevel = \"$7\"@" $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py
		sed -i "s@.*alg.Eff.*@alg.Eff = $8@" $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py
		sed -i "s@.*alg.runNum.*@alg.runNum = $9@" $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py
		sed -i "s@.*alg.FileName.*@alg.FileName = \"mce_$4_$linenumber\"@" $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py

		sed -i "s@.*alg.PtCutMult =.*@alg.PtCutMult = ${12}@" $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py
		sed -i "s@.*alg.EtaMult =.*@alg.EtaMult = ${13}@" $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py
		sed -i "s@.*alg.PtCutTruthMult.*@alg.PtCutTruthMult = ${14}@" $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py
		sed -i "s@.*alg.EtaTruthMult.*@alg.EtaTruthMult = ${15}@" $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py

		sed -i "s@.*alg.PrimLim.*@alg.PrimLim = ${16}@" $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py
		sed -i "s@.*alg.Cent.*@alg.Cent = ${17}@" $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py
		sed -i "s@.*alg.Cent.*@alg.hasJets = ${18}@" $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py
		sed -i "s@.*alg.Cent.*@alg.JZ = ${19}@" $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py
		#sed -i "s@^ROOT.SH.ScanDir().filePattern.*@ROOT.SH.ScanDir().filePattern( \'\*${14}\*\').scan( sh, inputFilePath )@" $tempdir/'tempout'$3_$linenumber/ATestRun_eljob.py
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
