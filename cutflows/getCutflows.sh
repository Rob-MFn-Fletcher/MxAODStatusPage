# dumps the cutflows of the mH=125 MxAODs to txt files, which are read by index.php
[[ -z "$1" ]] && echo Please enter an htag as an argument! E.G source getCutflows.sh h011 && return
#datasetDir=/Users/athompso/MxAODwebsite/datasets
htag=$1
#datasetDir=/eos/atlas/atlascerngroupdisk/phys-higgs/HSG1/MxAOD
#mcDir=mc_25ns
#dataDir=data_25ns
Samples=($(eos ls $datasetDir/$htag/$mcDir/ | grep 125))


# mc
for fileName in ${Samples[@]}; do
    file="root://eosatlas.cern.ch/$datasetDir/$htag/$mcDir/$fileName"
    echo $file
    base=$(basename ${file})
    fileType=${fileName%.MxAOD*}
    root -l -q -b "printCutflow.c(\"${file}\")" 2>err.log  1> ${fileType}.txt
    sed -i'.og' "1d" ${fileType}.txt
    sed -i'.og' "s/^ *//g" ${fileType}.txt
    sed -i'.og' "s/Processing.*/                    $fileType/g" ${fileType}.txt
done

# All Data

fileName=$(eos ls $datasetDir/$htag/$dataDir/ | grep periodAll25ns)
file="root://eosatlas.cern.ch/$datasetDir/$htag/$dataDir/$fileName"
echo $file
base=$(basename ${file})
fileType=${fileName%.MxAOD*}
root -l -q -b "printCutflowData.c(\"${file}\")" 2>err.log  1> ${fileType}.txt
sed -i'.og' "1d" ${fileType}.txt
sed -i'.og' "s/^ *//g" ${fileType}.txt
sed -i'.og' "s/Processing.*/                    $fileType/g" ${fileType}.txt


rm *.og

