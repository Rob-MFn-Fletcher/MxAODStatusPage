
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
SampleDirs+=($(eos ls $datasetDir/$htagNew/ | grep data | grep -v root | grep -v -i nogrl ))

Samples=()
for dir in ${SampleDirs[@]}; do
  Samples+=($(eos ls $datasetDir/$htagNew/$dir/runs/ | grep .root ))
done
# check existance of all datasets
MissingSamplesFile="../data/${htagNew}/MissingSamples_data.txt"



FullSamplesList=($(cat $dataList | grep '^.' | grep -v '#' | awk '{print $2}' | sed 's/.*TeV\.//g' | sed 's/.physics_Main.*//g'))
AllSamplesExist="YES"
MissingSamples=()
echo The Following Samples are in the master list but not on EOS!  > $MissingSamplesFile
for runNumber in ${FullSamplesList[@]}; do
  check=$(echo "${Samples[@]}" | grep "${runNumber}")
  [[ -z "$check" ]] && AllSamplesExist="NO" && MissingSamples+=($runNumber)
done
if [[ $AllSamplesExist == "YES" ]]; then
  echo All Run Numbers Accounted For! 
  echo 'None' >> $MissingSamplesFile
else
  echo The Following Run Numbers are Missing! : ${MissingSamples[@]}  
  for sample in ${MissingSamples[@]}; do
    echo $sample >> $MissingSamplesFile
  done
fi


for DIR in ${SampleDirs[@]}; do

# output text files
  uncolumnizedOutput="../data/${htagNew}/temp_${DIR}.out"
  columnizedOutput="../data/${htagNew}/ValidationTable_${DIR}.txt"
  samplesMissingParentsOutput="../data/${htagNew}/samplesMissingParents_${DIR}.txt"
  samplesMissingEventsOutput="../data/${htagNew}/samplesMissingEvents_${DIR}.txt"

  RunSampleDirEOS=$datasetDir/$htagNew/$DIR/runs
  RunSampleDirXrootd=$EOSMOUNTDIR/$RunSampleDirEOS
  
  Samples=()
  Samples+=($(eos ls $RunSampleDirEOS/ | grep .root ))
  
  
  
  # check N events in all runs
  totalMxAODeventsRunOver=$((0)) && totalDAODeventsAMI=$((0)) && totalAODeventsAMI=$((0))
  totalMxAODPreSel=$((0))  && totalMxAODPassed=$((0)) #&& #totalMxAODisPassedFlag=$((0)) && 
  totalMxAODisPassedPreFlag=$((0)) && totalAODeventsBookkeeper=$((0)) && totalDAODeventsBookkeeper=$((0))
  
  #echo table is columnized at the end in the output file in $columnizedOutput
  echo 'samples where not all DAOD events were run over( DAOD_AMI > NevtsRunOverMxAOD )' >$samplesMissingEventsOutput
  echo 'The Following samples have no parent in '$dataList :  > $samplesMissingParentsOutput
 
  echo Runs in $DIR |  tee $uncolumnizedOutput
  echo runNumber AOD_AMI AOD_Bookkeeper DAOD_AMI DAOD_Bookkeeper NevtsRunOverMxAOD NevtsPassedPreCutflowMxAOD NevtsIsPassedPreFlagMxAOD | tee -a $uncolumnizedOutput
  #echo runNumber NeventsAOD_AMI NeventsAOD_Bookkeeper NeventsDAOD_AMI NeventsDAOD_Bookkeeper NeventsRunOverMxAOD NeventsPassedPreCutflowMxAOD NeventsIsPassedPreFlagMxAOD
  
  for SAMPLE in ${Samples[@]}; do
    runNumber=${SAMPLE%.physics_Main*}
    runNumber=${runNumber#*TeV.}
    MxAODparentName=$(cat $dataList | grep "$runNumber" | awk '{print $2}')
    MxAODparentName=${MxAODparentName%?}
    MxAODparentName=${MxAODparentName#*:}
    [[ -z "$MxAODparentName" ]] && echo $runNumber >> $samplesMissingParentsOutput && continue
    if [[ "$MxAODparentName" =~ DAOD_HIGG1D1 ]]; then # data is always DAOD
      DxAODname=${MxAODparentName}
      
      nEventsDxAOD_AMI=0 && nEventsDxAOD_Bookkeeper=0 && nEventsAOD_AMI=0 && nEventsAOD_Bookkeeper=0
      nEventsRunOverMxAOD=0 && nEventsIsPassedPre=0 && nEventsPreSelMxAOD=0 
      
      nEventsDxAOD_AMI=$(ami show dataset prov "$DxAODname" | grep ' DAOD_HIGG1D1' | awk '{print $8}' ) # | grep -m 1 ' DAOD_HIGG1D1' | awk '{print $8}')
      nEventsDxAOD_Bookkeeper=$(echo "CutFlow_Run${runNumber#00}->GetBinContent(2)" | root -l $RunSampleDirXrootd/$SAMPLE 2>err.log |  grep "Double" | awk '{print $2}' )
      nEventsDxAOD_Bookkeeper=$(printf '%.0f' $nEventsDxAOD_Bookkeeper)

      nEventsAOD_AMI=$(ami show dataset prov $DxAODname | grep -m 1 ' AOD ' | awk '{print $8}')
      nEventsAOD_Bookkeeper=$(echo "CutFlow_Run${runNumber#00}->GetBinContent(1)" | root -l $RunSampleDirXrootd/$SAMPLE 2>err.log |  grep "Double" | awk '{print $2}' ) 
      nEventsAOD_Bookkeeper=$(printf '%.0f' $nEventsAOD_Bookkeeper)

      nEventsRunOverMxAOD=$(echo "CutFlow_Run${runNumber#00}->GetBinContent(3)" | root -l $RunSampleDirXrootd/$SAMPLE 2>err.log |  grep "Double" | awk '{print $2}' )
      nEventsRunOverMxAOD=$(printf '%.0f' $nEventsRunOverMxAOD) # answer is in scientific notation, fix that!
      
      nEventsIsPassedPre=$(echo "CollectionTree->GetEntries(\"HGamEventInfoAuxDyn.isPassedBasic && HGamEventInfoAuxDyn.isPassedPreselection\")" | root -l $RunSampleDirXrootd/$SAMPLE 2>err.log | grep Long | sed 's/^(.*)//g')
  
      nEventsPreSelMxAOD=$(echo "CutFlow_Run${runNumber#00}->GetBinContent(10)" | root -l $RunSampleDirXrootd/$SAMPLE 2>>err.log |  grep "Double" | awk '{print $2}' )
      nEventsPreSelMxAOD=$(printf '%.0f' $nEventsPreSelMxAOD)
  
      extra=""
      [[ ! "$nEventsDxAOD_AMI" -eq "$nEventsRunOverMxAOD"  ]] && extra='!!!!' 
      [[ "$nEventsDxAOD_AMI" -gt "$nEventsRunOverMxAOD"  ]] && extra='!!!!' && echo ${runNumber} >> $samplesMissingEventsOutput
      [[ ! "$nEventsPreSelMxAOD" -eq "${nEventsIsPassedPre}" ]] && extra='!!!!'
      #echo ${runNumber#00} $nEventsAOD_AMI $nEventsDxAOD_Bookkeeper $nEventsDxAOD_AMI $nEventsAOD_Bookkeeper ${nEventsRunOverMxAOD} $nEventsPreSelMxAOD $nEventsPassedAllMxAOD
      #echo ${runNumber#00} $nEventsAOD_AMI $nEventsDxAOD_AMI ${nEventsRunOverMxAOD} $nEventsPreSelMxAOD $nEventsIsPassedPre $nEventsPassedAllMxAOD $nEventsIsPassedFlag
      echo ${runNumber#00} $nEventsAOD_AMI $nEventsAOD_Bookkeeper $nEventsDxAOD_AMI $nEventsDxAOD_Bookkeeper ${nEventsRunOverMxAOD} $nEventsPreSelMxAOD ${nEventsIsPassedPre}$extra | tee -a $uncolumnizedOutput
      totalMxAODeventsRunOver=$(( $totalMxAODeventsRunOver + $nEventsRunOverMxAOD  ))
      totalDAODeventsAMI=$(( $totalDAODeventsAMI + $nEventsDxAOD_AMI  ))
      totalDAODeventsBookkeeper=$(( $totalDAODeventsBookkeeper + $nEventsDxAOD_Bookkeeper))
      totalAODeventsAMI=$(( $totalAODeventsAMI + ${nEventsAOD_AMI} ))
      totalAODeventsBookkeeper=$(( $totalAODeventsBookkeeper + ${nEventsAOD_Bookkeeper} ))
      totalMxAODPreSel=$(( $totalMxAODPreSel + ${nEventsPreSelMxAOD}))
      totalMxAODisPassedPreFlag=$(($totalMxAODisPassedPreFlag+ $nEventsIsPassedPre)) 
      
      continue
    fi
  done
  extra=""
  [[ ! "$totalMxAODeventsRunOver" -eq "$totalDAODeventsAMI"  ]] && extra='--NOT_AMI_MATCH'
  [[ ! "${totalMxAODPreSel}" -eq "$totalMxAODisPassedPreFlag" ]] && extra='--!!!!'
  echo TOTAL $totalAODeventsAMI $totalAODeventsBookkeeper $totalDAODeventsAMI $totalDAODeventsBookkeeper ${totalMxAODeventsRunOver} ${totalMxAODPreSel} ${totalMxAODisPassedPreFlag}$extra | tee -a $uncolumnizedOutput #>> temp.out
  
  Sample=()
  Sample+=($(eos ls $datasetDir/$htagNew/$DIR/ | grep .root  ))
  #echo ${Sample[0]}
  if [[ ! -z "${Sample[0]}" ]] ; then
    #echo $EOSMOUNTDIR/$datasetDir/$htagNew/data_25ns/${Sample[0]}
    root -l -b -q "printCutflowData.c(\"$EOSMOUNTDIR/$datasetDir/$htagNew/$DIR/${Sample[0]}\")" 2>>err.log > period25nsCutflow.txt
    
    nEventsAOD_Bookkeeper=$(cat period25nsCutflow.txt | grep "{xAOD}" | awk '{print $2}')
    nEventsDxAOD_Bookkeeper=$(cat period25nsCutflow.txt | grep "{DxAOD}" | awk '{print $2}')
    
    nEventsRunOverMxAOD=$(cat period25nsCutflow.txt | grep "All events" | awk '{print $3}')
    nEventsPreSelMxAOD=$(cat period25nsCutflow.txt | grep "ambiguity" | awk '{print $3}')
    nEventsIsPassedPreFlag=$(echo "CollectionTree->GetEntries(\"HGamEventInfoAuxDyn.isPassedBasic &&HGamEventInfoAuxDyn.isPassedPreselection\")" | root -l $EOSMOUNTDIR/$datasetDir/$htagNew/$DIR/${Sample[0]} 2>>err.log | grep Long | sed 's/^(.*)//g')
    echo combinedFile N/A $nEventsAOD_Bookkeeper N/A $nEventsDxAOD_Bookkeeper ${nEventsRunOverMxAOD} $nEventsPreSelMxAOD $nEventsIsPassedPreFlag | tee -a $uncolumnizedOutput
  fi  
  
  
  cat $uncolumnizedOutput |  column -t > $columnizedOutput

  [[ "$(cat $samplesMissingParentsOutput | wc -l)" -eq 1  ]] && echo None >> $samplesMissingParentsOutput
  [[ "$(cat $samplesMissingEventsOutput | wc -l)" -eq 1  ]] && echo None >> $samplesMissingEventsOutput

done

