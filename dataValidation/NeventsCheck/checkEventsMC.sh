# loops through all samples on EOS, gets the parent DAOD or AOD from the input file,
# and compares in the AMI, bookkeeper, and data in the MxAOD, outputing to a file if
# not all DAOD events were ran over, if a sample is missing from EOS, and if an MxAOD
# does not have a parent in the input file


htagNew=$1
dataList=$2

[[ ! -d ../data/${htagNew} ]] && mkdir -p ../data/${htagNew}

if [[ ! $htagNew =~ h[0-9][0-9][0-9]  ]]; then
  echo please use htag as first argument!
  echo e.g. source checkEventsData.sh h012 data.txt
  return
fi
if [[ -z "$dataList" ]] || [[ ! -e "$dataList" ]]; then
  echo please specify a file with the data DxAODs as the 2nd argument!
  echo e.g. source checkEventsData.sh h012 data.txt
  return
fi
[[ ! -z "$(which ami 2>&1 | grep 'no ami')" ]] && source setup.sh

SampleDirs=()
SampleDirs+=($(eos ls $datasetDir/$htagNew/ | grep -v data | grep -v Sys | grep -v debug))

Samples=()
for DIR in ${SampleDirs[@]}; do
  Samples+=($(eos ls $datasetDir/$htagNew/$DIR/ | grep .root  | grep -v Sys ))
done

# output text files
MissingSamplesFile="../data/${htagNew}/MissingSamples_MC.txt"
uncolumnizedOutput="../data/${htagNew}/temp_MC.out"
columnizedOutput="../data/${htagNew}/ValidationTable_MC.txt"
samplesMissingParentsOutput="../data/${htagNew}/samplesMissingParents_MC.txt"
samplesMissingEventsOutput="../data/${htagNew}/samplesMissingEvents_MC.txt"

FullSamplesList=($(cat $dataList | grep '^.' | grep -v '#' | awk '{print $1}'))
AllSamplesExist="YES"
MissingSamples=()
echo The Following Samples are in the master list but not on EOS!  > $MissingSamplesFile
for sampleType in ${FullSamplesList[@]}; do
  check=$(echo "${Samples[@]}" | grep "${sampleType}")
  [[ -z "$check" ]] && AllSamplesExist="NO" && MissingSamples+=($sampleType)
done
if [[ $AllSamplesExist == "YES" ]]; then
  echo All Samples Accounted For! # | tee temp.out
  echo None! >> $MissingSamplesFile
else
  echo The Following Samples are Missing! : ${MissingSamples[@]}
  for sample in ${MissingSamples[@]}; do 
    echo $sample >> $MissingSamplesFile
  done
fi

#echo table is columnized at the end in the output file in $columnizedOutput
#echo Sample AOD_AMI AOD_Bookkeeper DAOD_AMI DAOD_Bookkeeper NevtsRunOverMxAOD NevtsPassedPreCutflowMxAOD NevtsIsPassedPreFlagMxAOD | tee $uncolumnizedOutput
printf '%-36s %-9s %-16s %-10s %-17s %-19s %-28s %-12s\n' Sample AOD_AMI AOD_Bookkeeper DAOD_AMI DAOD_Bookkeeper NevtsRunOverMxAOD NevtsPassedPreCutflowMxAOD NevtsIsPassedPreFlagMxAOD | tee $columnizedOutput

echo 'samples where not all DAOD events were run over( DAOD_AMI != NevtsRunOverMxAOD )' >$samplesMissingEventsOutput
echo 'The Following samples have no parent in '"$dataList :"  > $samplesMissingParentsOutput
#echo 'The Following samples have disagreements between the cutflow and the file: '

for sample in ${Samples[@]}; do
  #echo $sampleType
  sampleType=${sample%.MxAOD*}
  sampleType=$(echo $sampleType | sed 's/mc.*\.//g')
  [[ ! -z "$(eos ls $datasetDir/$htagNew/$DIR/$sample 2>/dev/null)"  ]] && filePath="$EOSMOUNTDIR/$datasetDir/$htagNew/$DIR/$sample" && sampleDir=$DIR
     

  MxAODparentName=$(cat $dataList | grep "$sampleType\ " | awk '{print $2}')
  MxAODparentName=${MxAODparentName%?}
  MxAODparentName=${MxAODparentName#*:}
  #[[ -z "$MxAODparentName" ]] && echo no Parent for $sampleType in mc.txt file $mcList, going on... | tee -a ../data/${htagNew}/temp.out  && continue
  [[ -z "$MxAODparentName" ]] && echo $sample >> $samplesMissingParentsOutput && continue
  if [[ "$MxAODparentName" =~ DAOD_HIGG1D1 ]]; then 
    DxAODname=${MxAODparentName}
    
    nEventsDxAOD_AMI=$(ami show dataset prov "$DxAODname" | grep ' DAOD_HIGG1D1' | awk '{print $8}' ) # | grep -m 1 ' DAOD_HIGG1D1' | awk '{print $8}')
    #echo "got AMI DAOD"
    #echo echo "((TH1F *)_file0->Get(\"CutFlow_${sampleType}\"))->GetBinContent(2)" '|' root -l $filePath '2>>err.log'
    nEventsDxAOD_Bookkeeper=$(echo "((TH1F *)_file0->Get(\"CutFlow_${sampleType}\"))->GetBinContent(2)" | root -l $filePath 2>>err.log |  grep "Double" | awk '{print $2}' )
    
    nEventsDxAOD_Bookkeeper=$(printf '%.0f' $nEventsDxAOD_Bookkeeper)
    #echo got BK DAOD

    nEventsAOD_AMI=$(ami show dataset prov $DxAODname | grep ' AOD ' | awk '{print $8}' | head -n 1)
    #echo got AOD MI
    nEventsAOD_Bookkeeper=$(echo "((TH1F *)_file0->Get(\"CutFlow_${sampleType}\"))->GetBinContent(1)" | root -l $filePath 2>>err.log |  grep "Double" | awk '{print $2}' )
    nEventsAOD_Bookkeeper=$(printf '%.0f' $nEventsAOD_Bookkeeper)
    #echo got AOD BK

    nEventsRunOverMxAOD=$(echo "((TH1F *)_file0->Get(\"CutFlow_${sampleType}\"))->GetBinContent(3)" | root -l $filePath 2>>err.log |  grep "Double" | awk '{print $2}' )
    nEventsRunOverMxAOD=$(printf '%.0f' $nEventsRunOverMxAOD) # answer is in scientific notation, fix that!
    #echo got NERO MxAOD

    nEventsIsPassedPre=$(echo "CollectionTree->GetEntries(\"HGamEventInfoAuxDyn.isPassedBasic && HGamEventInfoAuxDyn.isPassedPreselection\")" | root -l $filePath 2>>err.log | grep Long | sed 's/^(.*)//g')
    #echo got NEIPP

    nEventsPreSelMxAOD=$(echo "((TH1F *)_file0->Get(\"CutFlow_${sampleType}\"))->GetBinContent($PRESELECTION_NUM)" | root -l $filePath 2>>err.log |  grep "Double" | awk '{print $2}' )
    nEventsPreSelMxAOD=$(printf '%.0f' $nEventsPreSelMxAOD)
    #echo got NEPSM 
    extra=""
    [[ ! "$nEventsDxAOD_AMI" -eq "$nEventsRunOverMxAOD"  ]] && extra='!!!!' 
    [[ "$nEventsDxAOD_AMI" -gt "$nEventsRunOverMxAOD"  ]] && extra='!!!!' && echo ${sample} >> $samplesMissingEventsOutput
    [[ ! "$nEventsPreSelMxAOD" -eq "${nEventsIsPassedPre}" ]] && extra='!!!!'
    
    #echo ${sampleType} $nEventsAOD_AMI $nEventsAOD_Bookkeeper $nEventsDxAOD_AMI $nEventsDxAOD_Bookkeeper ${nEventsRunOverMxAOD} $nEventsPreSelMxAOD ${nEventsIsPassedPre}$extra | tee -a $uncolumnizedOutput
    printf '%-36s %-9s %-16s %-10s %-17s %-19s %-28s %-12s\n' ${sampleType} $nEventsAOD_AMI $nEventsAOD_Bookkeeper $nEventsDxAOD_AMI $nEventsDxAOD_Bookkeeper ${nEventsRunOverMxAOD} $nEventsPreSelMxAOD ${nEventsIsPassedPre}$extra | tee -a $columnizedOutput
  elif [[ "$MxAODparentName" =~ \.AOD\. ]]; then  
    AODname=$MxAODparentName
    #echo $AODname
    nEventsAOD_AMI=$(ami show dataset prov $AODname | grep ' AOD '  | awk '{print $8}' | head -n 1)
    nEventsAOD_Bookkeeper=$(echo "((TH1F *)_file0->Get(\"CutFlow_${sampleType}\"))->GetBinContent(1)" | root -l $filePath 2>>err.log |  grep "Double" | awk '{print $2}' | printf '%.0f') 
    nEventsRunOverMxAOD=$(echo "((TH1F *)_file0->Get(\"CutFlow_${sampleType}\"))->GetBinContent(3)" | root -l $filePath 2>>err.log |  grep "Double" | awk '{print $2}' )
    nEventsRunOverMxAOD=$(printf '%.0f' $nEventsRunOverMxAOD)
    nEventsIsPassedPre=$(echo "CollectionTree->GetEntries(\"HGamEventInfoAuxDyn.isPassedBasic && HGamEventInfoAuxDyn.isPassedPreselection\")" | root -l $filePath 2>>err.log | grep Long | sed 's/^(.*)//g')
    nEventsPreSelMxAOD=$(echo "((TH1F *)_file0->Get(\"CutFlow_${sampleType}\"))->GetBinContent($PRESELECTION_NUM)" | root -l $filePath 2>>err.log |  grep "Double" | awk '{print $2}' )
    nEventsPreSelMxAOD=$(printf '%.0f' $nEventsPreSelMxAOD)
    [[ ! "$nEventsAOD_AMI" -eq "$nEventsRunOverMxAOD"  ]] && echo ${sample} >> $samplesMissingEventsOutput 
    #echo $sampleType $nEventsAOD_AMI $nEventsAOD_Bookkeeper N/A N/A ${nEventsRunOverMxAOD} $nEventsPreSelMxAOD ${nEventsIsPassedPre} | tee -a $uncolumnizedOutput
    printf '%-36s %-9s %-16s %-10s %-17s %-19s %-28s %-12s\n' $sampleType $nEventsAOD_AMI $nEventsAOD_Bookkeeper N/A N/A ${nEventsRunOverMxAOD} $nEventsPreSelMxAOD ${nEventsIsPassedPre} | tee -a $columnizedOutput
  fi
done

[[ "$(cat $samplesMissingParentsOutput | wc -l)" -eq 1  ]] && echo None >> $samplesMissingParentsOutput
[[ "$(cat $samplesMissingEventsOutput | wc -l)" -eq 1  ]] && echo None >> $samplesMissingEventsOutput

#cat $uncolumnizedOutput |  column -t > $columnizedOutput


