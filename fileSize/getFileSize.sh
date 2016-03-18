#!/bin/bash
source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh
asetup AthAnalysisBase,2.1.30,here

datasetDir=/eos/atlas/atlascerngroupdisk/phys-higgs/HSG1/MxAOD
mcDir=mc_25ns

htag=$1
inputFileType=PowhegPy8_VBF125_small

inputFile=$(eos ls $datasetDir/$htag/$mcDir/ | grep $inputFileType)
./checkFileSummarize.py root://eosatlas.cern.ch/$datasetDir/$htag/$mcDir/$inputFile > fileSize.txt
sed -i'.og' "1d" fileSize.txt
sed -i'.og' "1d" fileSize.txt
rm *.og



