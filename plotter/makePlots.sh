htag=h011
datasetDir=/eos/atlas/atlascerngroupdisk/phys-higgs/HSG1/MxAOD
mcDir=mc_25ns
dataDir=data_25ns
AllSysDir=AllSys
PhotonSysDir=PhotonSys

num=${htag:1}
num=$(echo $num | sed "s/^0*//g")
htagPrevNum=$(($num - 1))
htagPrevNum=$(printf %03d $htagPrevNum)
htagOld=h$htagPrevNum


#eos ls $datasetDir/$htag/$mcDir/ | grep 125 &> MxAODs.txt
#eos ls $datasetDir/$htag/$dataDir/ &>> MxAODs.txt
#eos ls $datasetDir/$htag/$AllSysDir/ &>> MxAODs.txt
#eos ls $datasetDir/$htag/$PhotonSysDir/ &>> MxAODs.txt


Samples=()
for DIR in ${MXAODDIRS[@]}; do
  [[ $DIR =~ AllSys ]] && continue # All Sys files might be folders, need to figure out how to handle
  Samples+=($(eos ls $datasetDir/$htag/$DIR/ | grep 125))
  #break
done
echo starting plots loop at $(date)
#echo ${Samples[@]}
for fileName in ${Samples[@]}; do 
  #echo $fileName 
  fileNew=""
  sampleDir=""
  for DIR in ${MXAODDIRS[@]}; do
    [[ ! -z "$(eos ls $datasetDir/$htag/$DIR/$fileName 2>/dev/null)"  ]] && fileNew="root://eosatlas.cern.ch/$datasetDir/$htag/$DIR/$fileName" && sampleDir=$DIR
  done 
  # folder files will not work properly and probably will cause a crash
  #[[ ! -z $(eos ls $datasetDir/$htag/$DIR/$fileName/)  ]] && echo "MxAOD with multiple files found, skipping..." && continue
  fileType=${fileName%.MxAOD*}
  fileOldName=$(eos ls $datasetDir/$htagOld/$sampleDir/ | grep ${fileType}.MxAOD)
  fileOld="root://eosatlas.cern.ch/$datasetDir/$htagOld/$sampleDir/$fileOldName"
  
  [[ -z "$fileOldName" ]] && echo old file of type $fileType not found, skipping plot... && continue
  echo running on sample: $fileName

  # need to make folder for plots if it is a new sample (root won't create the folder)
  [[ ! -d "samples/$fileName" ]] && mkdir -p samples/$fileName
  varsStringArray=$(echo ${VARSFORPLOTS[@]} | sed 's/^/{\\"/g' | sed 's/$/\\"}/g' | sed 's/ /\\",\\"/g')
  root -l -b -q "plotter.c(\"${fileOld}\",\"${fileNew}\")" 2> err.log

  cat err.log | grep -v 'Warning in <TClass::Init>:' | grep -v 'Error in <TBranchElement::InitInfo>:' > usefulErr.log



done
echo end of plots loop at $(date)


