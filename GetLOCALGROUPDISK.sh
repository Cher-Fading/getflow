input=$1'.txt'
>txts/$1_$2_pnfs.txt
while IFS= read -r line; do
rucio list-file-replicas --rse BNL-OSG2_LOCALGROUPDISK $line >>txts/$1_$2_pnfs.txt
done<$input
root -b -q -l 'get_to_root_pnfs.cpp("'$1'","'$2'","BNL-OSG2_LOCALGROUPDISK")'
