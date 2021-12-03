rucio list-file-replicas --expression BNL-OSG2_PHYS-HI $1 > txts/$2_$3_pnfs.txt
root -b -q -l 'get_to_root_pnfs.cpp("'$2'","'$3'","BNL-OSG2_PHYS-HI")'