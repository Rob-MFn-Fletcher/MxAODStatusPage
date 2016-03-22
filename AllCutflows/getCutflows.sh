# dumps the cutflows of the mH=125 MxAODs to txt files, which are read by index.php
[[ -z "$1" ]] && echo Please enter an htag as an argument! E.G source getCutflows.sh h011 h010 && return
[[ -z "$2" ]] && echo Please enter an htag as an argument! E.G source getCutflows.sh h011 h010 && return
htag=$1
#datasetDir=/eos/atlas/atlascerngroupdisk/phys-higgs/HSG1/MxAOD
#mcDir=mc_25ns
#dataDir=data_25ns
#Samples=($(eos ls $datasetDir/$htag/$mcDir/ ))

htagNew=$1
htagOld=$2

[[ -z "$datasetDir" ]] && echo Please source the setup script!! && return

for htag in $htagNew $htagOld; do
  break 
  Samples=()
  for DIR in ${MXAODDIRS[@]}; do
    Samples+=($(eos ls $datasetDir/$htag/$DIR/ ))
    #break
  done
  
  echo "Making Cutflows for all samples on EOS for $htag..."
  
  for fileName in ${Samples[@]}; do
      file=""
      for DIR in ${MXAODDIRS[@]}; do
        [[ ! -z "$(eos ls $datasetDir/$htag/$DIR/$fileName 2>/dev/null)"  ]] && file="root://eosatlas.cern.ch/$datasetDir/$htag/$DIR/$fileName"
      done
      #file="root://eosatlas.cern.ch/$datasetDir/$htag/$mcDir/$fileName"
      echo $file
      base=$(basename ${file})
      fileType=${fileName%.MxAOD*}
      root -l -q -b "printCutflow.c(\"${file}\")" 2>err.log 1> ${fileName}.txt
      sed -i'.og' "1d" ${fileName}.txt
      sed -i'.og' "s/^ *//g" ${fileName}.txt
      sed -i'.og' "s/Processing.*/                    $fileType/g" ${fileName}.txt
  done
  
  

done

#for DIR in ${MXAODDIRS[@]}; do
#  Samples+=($(eos ls $datasetDir/$htagNew/$DIR/ ))
#  #break
#done

# make diff cutflows to compare old and new cutflows
for filename in ${Samples[@]}; do
  fileType=${filename%.MxAOD*}
  echo $fileType
  diffCutflowName=$(echo $filename | sed "s/h[0-9][0-9][0-9]/diff/g")
  oldCutflowName=$(echo $filename | sed "s/h[0-9][0-9][0-9]/$htagOld/g")
  newCutflowName=$(echo $filename | sed "s/h[0-9][0-9][0-9]/$htagNew/g")
  ./diffCutflow.py ${oldCutflowName}.txt ${newCutflowName}.txt && \
    sed -i'.og' "1 i\             $fileType" ${diffCutflowName}.txt
done
rm *.og



