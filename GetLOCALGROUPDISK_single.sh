rucio list-file-replicas --expression BNL-OSG2_LOCALGROUPDISK data18_hi.00$1.calibration_PCPEB.merge.AOD.$2 > $1_PC_pnfs.txt
rucio list-file-replicas --expression BNL-OSG2_LOCALGROUPDISK data18_hi.00$1.calibration_CCPEB.merge.AOD.$2 > $1_CC_pnfs.txt
root -b -q -l 'get_to_root_pnfs.cpp("'$1'","PC")'
root -b -q -l 'get_to_root_pnfs.cpp("'$1'","CC")'