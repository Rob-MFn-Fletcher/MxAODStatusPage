[[ -z "$1" ]] && echo "NEED 1st arugment!" && return
[[ -z "$2" ]] && echo "NEED 2nd arugment!" && return

[[ -z "$EXAMPLEFILE" ]] && echo "please source the setup script" && return

htag=$1
htagOld=$2



Samples=()
for DIR in ${MXAODDIRS[@]}; do
  #[[ $DIR =~ AllSys ]] && continue # All Sys files might be folders, need to figure out how to handle
  Samples+=($(eos ls $datasetDir/$htag/$DIR/ ))
  #break
done
echo starting plots loop at $(date)
echo
for fileName in ${Samples[@]}; do 
  #[[ -d "samples/$fileName" ]] && echo plots produced for $fileName, skipping... && continue
  fileNew=""
  sampleDir=""
  for DIR in ${MXAODDIRS[@]}; do
    [[ ! -z "$(eos ls $datasetDir/$htag/$DIR/$fileName 2>/dev/null)"  ]] && fileNew="root://eosatlas.cern.ch/$datasetDir/$htag/$DIR/$fileName" && sampleDir=$DIR
  done 
  
  fileType=${fileName%.MxAOD*}
  fileOldName=$(eos ls $datasetDir/$htagOld/$sampleDir/ | grep ${fileType}.MxAOD)
  fileOld="root://eosatlas.cern.ch/$datasetDir/$htagOld/$sampleDir/$fileOldName"
 
  echo running on sample: $fileName

  # need to make folder for plots if it is a new sample (root won't create the folder)
  [[ ! -d "samples/$fileName" ]] && mkdir -p samples/$fileName
  #varsStringArray=$(echo ${VARSFORPLOTS[@]} | sed 's/^/{\\"/g' | sed 's/$/\\"}/g' | sed 's/ /\\",\\"/g') 
  varsStringArray=$(echo ${VARSFORPLOTS[@]} | sed "s/^/std::string___plotVars[${#VARSFORPLOTS[@]}]={\"/g" | sed 's/$/"};/g' | sed 's/ /","/g' | sed 's/___/ /g')
  echo $varsStringArray > Root/plotVars.h
  echo '// This file is produced automatically in makePlots.sh. To change the variables that are plotted, change the list in the variable VARSFORPLOTS in the setup script' >> Root/plotVars.h
  
  nFilesNew=$(eos ls $datasetDir/$htag/$sampleDir/$fileName | wc -l)
  if [[ ! -z "$fileOldName" ]]; then
    nFilesOld=$(eos ls $datasetDir/$htagOld/$sampleDir/$fileOldName | wc -l)
  else
    nFilesOld=0
  fi

  root -l -b -q "Root/plotAllVars.c(\"${fileOld}\",${nFilesOld},\"${fileNew}\",${nFilesNew})"  2>> err.log # lots of errors that don't matter...
  #if [[ -z "$fileOldName" ]]; then 
  #  root -l -b -q "Root/plotOnlyNew.c(\"${fileNew}\")" 2>> err.log
  #else
  #  #root -l -b -q "Root/plotter.c(\"${fileOld}\",\"${fileNew}\")" 2>> err.log
  #  root -l -b -q "Root/plotBothReleases.c(\"${fileOld}\",${nFilesOld},\"${fileNew}\",${nFilesNew})"  2>> err.log
  #fi


  cat err.log | grep -v 'Warning in <TClass::Init>:' | grep -v 'Error in <TBranchElement::InitInfo>:' > usefulErr.log



done
echo
echo end of plots loop at $(date)


