#!/bin/bash
[[ -z "$1" ]] && echo "NEED 1st arugment of htag!" && return
[[ -z "$datasetDir" ]] && echo "please source the setup script" && return
#source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh
[[ -z "$(command -v checkFile.py >/dev/null 2>&1 || echo NO)"  ]] || asetup AthAnalysisBase,2.3.34,here
htag=$1

[[ ! -d htags ]] && mkdir htags
[[ ! -d htags/$htag ]] && mkdir htags/$htag


SampleDirs=()
SampleDirs+=($(eos ls $datasetDir/$htagNew/))

Samples=()
for DIR in ${SampleDirs[@]}; do
  Samples+=($(eos ls $datasetDir/$htagNew/$DIR/ | grep .root | grep '\.MxAOD\.'))
done

inputFile=${Samples[0]}
for DIR in ${SampleDirs[@]}; do
  [[ ! -z "$(eos ls $datasetDir/$htagNew/$DIR/$inputFile 2>/dev/null)"  ]] && filePath="$EOSMOUNTDIR/$datasetDir/$htagNew/$DIR/$inputFile" && sampleDir=$DIR
done


#inputFile=$(eos ls $datasetDir/$htag/$mcDir/ | grep $EXAMPLEFILE)
./checkFileSummarize.py root://eosatlas.cern.ch/$datasetDir/$htag/$sampleDir/$inputFile 2>err.log 1> htags/$htag/fileSize.txt
sed -i'.og' "1d" htags/$htag/fileSize.txt
sed -i'.og' "1d" htags/$htag/fileSize.txt
rm htags/$htag/*.og



