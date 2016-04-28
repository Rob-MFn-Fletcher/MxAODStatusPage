# dumps the cutflows of the mH=125 MxAODs to txt files, which are read by index.php
[[ -z "$1" ]] && echo Please enter an htag as an argument! E.G source getCutflows.sh h011 && return
htag=$1
Samples=($(eos ls $datasetDir/$htag/$mcDir/ | grep 125))


# mc
echo '    updating nominal MC samples (mH=125)...'
resetProgressBar
for fileName in ${Samples[@]}; do
    file="root://eosatlas.cern.ch/$datasetDir/$htag/$mcDir/$fileName"
    #echo $file
    base=$(basename ${file})
    fileType=${fileName%.MxAOD*}
    root -l -q -b "printCutflow.c(\"${file}\")" 2>err.log  1> ${fileType}.txt
    sed -i'.og' "1d" ${fileType}.txt
    sed -i'.og' "s/^ *//g" ${fileType}.txt
    sed -i'.og' "s/Processing.*/                    $fileType/g" ${fileType}.txt
    tickProgressBar ${#Samples[@]}
done
endProgressBar
# All Data
echo '    updating data cutflow...'

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

