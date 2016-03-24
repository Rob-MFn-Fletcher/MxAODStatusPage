[[ -z "$1" ]] && echo "NEED 1st arugment!" && return
[[ -z "$2" ]] && echo "NEED 2nd arugment!" && return
echo starting at $(date)
htagNew=$1
htagOld=$2

[[ -z "$EXAMPLEFILE" ]] && echo "please source the setup script" && return

htag=$1

htagOld=$2


Samples=()
OldSamples=()
for DIR in ${MXAODDIRS[@]}; do
  Samples+=($(eos ls $datasetDir/$htag/$DIR/ ))
  OldSamples+=($(eos ls $datasetDir/$htagOld/$DIR/ ))
done


for sample in ${Samples[@]}; do
  echo $sample
  #for DIR in ${MXAODDIRS[@]}; do
  #  [[ ! -z "$(eos ls $datasetDir/$htag/$DIR/$sample 2>/dev/null)"  ]] && fileNew="root://eosatlas.cern.ch/$datasetDir/$htag/$DIR/$sample" && sampleDir=$DIR
  #done
  
  if [[ "$sample" =~ $DATANAME ]]; then
    sampleDir=$dataDir
  else
    for i in $(seq 0 ${#MXAOD_MC_DIRS[@]}); do
      [[ ! -z $(echo $sample | grep "\.${MXAOD_MC_TYPES[i]}\." ) ]] && sampleDir=${MXAOD_MC_DIRS[i]} && sampleType=${MXAOD_MC_TYPES[i]}
    done
  fi

  file="root://eosatlas.cern.ch/$datasetDir/$htag/$sampleDir/$sample"
  base=$(basename ${file})
  fileType=${sample%.MxAOD*}
  #oldSample=$(eos ls $datasetDir/$htagOld/$sampleDir/ | grep "${fileType}.MxAOD")
  oldSample=$(printf -- '%s\n' "${OldSamples[@]}" | grep "${fileType}.MxAOD" | grep "\.${sampleType}\.")
  diffCutflowName=$(echo $sample | sed "s/h[0-9][0-9][0-9]/diff/g")
  echo '<html>'                                             >pages/${sample}.php   
  echo '<html lang="en">'                                  >>pages/${sample}.php
  echo '<head>'                                            >>pages/${sample}.php
  echo ' <meta charset="utf-8" />'                         >>pages/${sample}.php
  echo "  <title>$fileType</title>"                        >>pages/${sample}.php
  echo '    <style>'                                       >>pages/${sample}.php
  echo '    h1 {text-align:center;}'                       >>pages/${sample}.php
  echo '    p {text-align:center;}'                        >>pages/${sample}.php
  echo '    </style>'                                      >>pages/${sample}.php
  echo '    <link rel="stylesheet" href="mystyle.css" />'  >>pages/${sample}.php
  echo '</head>'                                           >>pages/${sample}.php
  echo '<body bgcolor=white>  '                            >>pages/${sample}.php
  echo "<h1>$fileType Page</h1>"                           >>pages/${sample}.php
  echo '<p>'Location: $file'</p>'                          >>pages/${sample}.php
  echo '<table class="center">'                            >>pages/${sample}.php
  echo '<tr>'                                              >>pages/${sample}.php
  echo '<td><p>'$htag'</p></td>'                           >>pages/${sample}.php
  echo '<td><p>'$htagOld'</p></td>'                        >>pages/${sample}.php
  echo '<td><p>'difference'</p></td>'                      >>pages/${sample}.php
  echo '</tr>'                                             >>pages/${sample}.php
  echo '<tr>'                                              >>pages/${sample}.php
  echo '<td>''<object width="484" height="300" type="text/plain" 'data=\"../AllCutflows/cutflows/${sample}.txt\"' border="0"></object>''</td>' >>pages/${sample}.php
  if [[ ! -z "$oldSample" ]]; then
    echo '<td>''<object width="484" height="300" type="text/plain" 'data=\"../AllCutflows/cutflows/${oldSample}.txt\"' border="0"></object>''</td>' >>pages/${sample}.php
    echo '<td>''<object width="484" height="300" type="text/plain" 'data=\"../AllCutflows/cutflows/${diffCutflowName}.txt\"' border="0"></object>''</td>' >>pages/${sample}.php
  else
    echo '<td>'"No similar sample for htag ${htagOld}!"'</td>'
    echo '<td>''</td>'
  fi
  echo '</tr>'                                             >>pages/${sample}.php
  echo '</table>'                                          >>pages/${sample}.php
 
  for var in ${VARSFORPLOTS[@]}; do 

    echo '<object width="700" height="500" type="text/plain" 'data=\"../plotter/samples/${sample}/${sample}_${var}.png\"' border="0"></object>' >>pages/${sample}.php
  done
#  echo '<p><object width="484" height="300" type="text/plain" 'data=\"../AllCutflows/${sample}.txt\"' border="0"></object>' >>pages/${sample}.php
#  [[ ! -z  $oldSample ]] && echo '<object width="484" height="300" type="text/plain" 'data=\"../AllCutflows/${oldSample}.txt\"' border="0"></object>' >>pages/${sample}.php
#  echo '</p>'                                              >>pages/${sample}.php
  echo '</body>'                                           >>pages/${sample}.php
  echo '</html>'                                           >>pages/${sample}.php
  #break
done 


echo ending at $(date)

