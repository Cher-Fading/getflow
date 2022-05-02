#!/bin/bash
#input="/atlasgpfs01/usatlas/data/cher97/mc16_5TeV.txt"
# ./runallloop.sh no1 process no2 foldername no3 inputtxt no4 nsubs no5 skipn no6 pnfs
# for large dataset, use pnfs for storage

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
        mkdir -p $tempdir/'tempin'$2_$linenumber
        xrdcp 'root://dcgftp.usatlas.bnl.gov:1096/'$line $tempdir/'tempin'$2_$linenumber
        cd $tempdir/'tempin'$2_$linenumber
        filename=$(ls *.root*)
        echo $filename
        mkdir -p $tempdir/'tempout'$2_$linenumber
        cd $tempdir/'tempout'$2_$linenumber
        cp /usatlas/u/cher97/getflow/py/$2ATestRun_eljob.py $tempdir/'tempout'$2_$linenumber/ATestRun_eljob.py
        sed -i "s@^inputFilePath = .*@inputFilePath = '$tempdir/tempin$2_$linenumber'@" $tempdir/'tempout'$2_$linenumber/ATestRun_eljob.py
        sed -i "s@^ROOT.SH.ScanDir().filePattern(.*@ROOT.SH.ScanDir().filePattern( '$filename').scan( sh, inputFilePath )@" $tempdir/'tempout'$2_$linenumber/ATestRun_eljob.py
for (( i=0; i<$4; i++ )); do
mkdir -p /atlasgpfs01/usatlas/data/cher97/$2/sub$4.$i/
cp $tempdir/'tempout'$2_$linenumber/ATestRun_eljob.py $tempdir/'tempout'$2_$linenumber/ATestRun_eljob$4.$i.py
chmod +x $tempdir/'tempout'$2_$linenumber/ATestRun_eljob$4.$i.py
        sed -i "s@^alg.FileName.*@alg.FileName = \"mce_$1_$linenumber.$4.$i\"@" $tempdir/'tempout'$2_$linenumber/ATestRun_eljob$4.$i.py
	sed -i "s@^alg.Rem.*@alg.Rem = $i@" $tempdir/'tempout'$2_$linenumber/ATestRun_eljob$4.$i.py
        #echo $PWD
        $tempdir/'tempout'$2_$linenumber/ATestRun_eljob$4.$i.py --submission-dir=submitDir$4.$i
        cp $tempdir/tempout$2_$linenumber/submitDir$4.$i/data-myOutput/*.root /atlasgpfs01/usatlas/data/cher97/$2/sub$4.$i/mce_$1_$linenumber.$4.$i'.root'
        cp $tempdir/'tempout'$2_$linenumber/ATestRun_eljob$4.$i.py /atlasgpfs01/usatlas/data/cher97/$2/sub$4.$i/mce_$1_$linenumber.$4.$i'ATestRun_eljob.py'
        cp $tempdir/'tempout'$2_$linenumber/mce_$1_$linenumber.$4.$i'.txt' /atlasgpfs01/usatlas/data/cher97/$2/sub$4.$i/mce_$1_$linenumber.$4.$i'.txt'
done
        sleep 2
        rm -rf $tempdir/tempin$2_$linenumber
        rm -rf $tempdir/tempout$2_$linenumber
        rm -rf $tempdir
    fi
    linenumber=$((linenumber + 1))
done <$input
