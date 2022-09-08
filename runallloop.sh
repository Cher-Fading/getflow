#!/bin/bash
#input="/atlasgpfs01/usatlas/data/cher97/mc16_5TeV.txt"
# ./runallloop.sh no1 process no2 foldername no3 inputtxt no4 nsubs no5 comb no6 pnfs
# for large dataset, use pnfs for storage

input=~/getflow/txts/$3.txt
#input="mc16_5TeV_short.txt"
mkdir -p /atlasgpfs01/usatlas/data/cher97/$2

#indexline=$1
linenumber=0
comb=$5
outputnumber=$1
bg=$((comb * outputnumber))
ed=$((comb * (outputnumber+1) ))

tempdir=$(mktemp -d)
cd $tempdir
echo $tempdir
mkdir -p $tempdir/'tempin'$2_$bg

while IFS= read -r line; do
    if [ $bg -le $linenumber -a $ed -gt $linenumber ]; then
        echo $line
        xrdcp 'root://dcgftp.usatlas.bnl.gov:1096/'$line $tempdir/'tempin'$2_$bg
    fi
    linenumber=$((linenumber + 1))
done <$input

cd $tempdir/'tempin'$2_$bg
filename=$(ls *.root*)
echo $filename

mkdir -p $tempdir/'tempout'$2_$bg
cd $tempdir/'tempout'$2_$bg
cp /usatlas/u/cher97/getflow/py/$2ATestRun_eljob.py $tempdir/'tempout'$2_$bg/ATestRun_eljob.py
sed -i "s@^alg.numSubs.*@alg.numSubs=$4@" $tempdir/'tempout'$2_$bg/ATestRun_eljob.py
sed -i "s@^inputFilePath = .*@inputFilePath = '$tempdir/tempin$2_$bg'@" $tempdir/'tempout'$2_$bg/ATestRun_eljob.py
# sed -i "s@^ROOT.SH.ScanDir().filePattern(.*@ROOT.SH.ScanDir().filePattern( '*root*').scan( sh, inputFilePath )@" $tempdir/'tempout'$2_$bg/ATestRun_eljob.py
for (( i=0; i<$4; i++ )); do
    mkdir -p /atlasgpfs01/usatlas/data/cher97/$2/sub$4.$i/
    cp $tempdir/'tempout'$2_$bg/ATestRun_eljob.py $tempdir/'tempout'$2_$bg/ATestRun_eljob$4.$i.py
    chmod +x $tempdir/'tempout'$2_$bg/ATestRun_eljob$4.$i.py
    sed -i "s@^alg.FileName.*@alg.FileName = \"mce_$1_$bg.$4.$i\"@" $tempdir/'tempout'$2_$bg/ATestRun_eljob$4.$i.py
    sed -i "s@^alg.Rem.*@alg.Rem = $i@" $tempdir/'tempout'$2_$bg/ATestRun_eljob$4.$i.py
    #echo $PWD
    $tempdir/'tempout'$2_$bg/ATestRun_eljob$4.$i.py --submission-dir=submitDir$4.$i
    ls $tempdir/tempout$2_$bg/submitDir$4.$i/data-myOutput/*.root
    cp $tempdir/tempout$2_$bg/submitDir$4.$i/data-myOutput/*.root /atlasgpfs01/usatlas/data/cher97/$2/sub$4.$i/mce_$1_$bg-$ed.$4.$i'.root'
    cp $tempdir/'tempout'$2_$bg/ATestRun_eljob$4.$i.py /atlasgpfs01/usatlas/data/cher97/$2/sub$4.$i/mce_$1_$bg-$ed.$4.$i'ATestRun_eljob.py'
    cp $tempdir/'tempout'$2_$bg/mce_$1_$bg.$4.$i'.txt' /atlasgpfs01/usatlas/data/cher97/$2/sub$4.$i/mce_$1_$bg-$ed.$4.$i'.txt'
done
sleep 2
rm -rf $tempdir/tempin$2_$bg
rm -rf $tempdir/tempout$2_$bg
rm -rf $tempdir
