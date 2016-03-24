#!/bin/bash
[[ -z "$1" ]] && echo "NEED 1st arugment of htag!" && return
[[ -z "$EXAMPLEFILE" ]] && echo "please source the setup script" && return
source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh
asetup AthAnalysisBase,2.1.30,here
htag=$1

inputFile=$(eos ls $datasetDir/$htag/$mcDir/ | grep $EXAMPLEFILE)
./checkFileSummarize.py root://eosatlas.cern.ch/$datasetDir/$htag/$mcDir/$inputFile > fileSize.txt
sed -i'.og' "1d" fileSize.txt
sed -i'.og' "1d" fileSize.txt
rm *.og



