[[ -z "$1" ]] && echo "NEED 1st arugment!" && return
[[ -z "$2" ]] && echo "NEED 2nd arugment!" && return
echo starting at $(date)
htagNew=$1
htagOld=$2

[[ -z "$EXAMPLEFILE" ]] && echo "please source the setup script" && return
[[ ! -d pages ]] && mkdir pages

Samples=()
OldSamples=()
for DIR in ${MXAODDIRS[@]}; do
  Samples+=($(eos ls $datasetDir/$htag/$DIR/ ))
  OldSamples+=($(eos ls $datasetDir/$htagOld/$DIR/ ))
done


for sample in ${Samples[@]}; do
  echo $sample
  
  # Clunky way to get which folder the sample is in
  if [[ "$sample" =~ $DATANAME ]]; then
    sampleDir=$dataDir
  else
    for i in $(seq 0 ${#MXAOD_MC_DIRS[@]}); do
      [[ ! -z $(echo $sample | grep "\.${MXAOD_MC_TYPES[i]}\." ) ]] && sampleDir=${MXAOD_MC_DIRS[i]} && sampleType=${MXAOD_MC_TYPES[i]}
    done
  fi

  file="root://eosatlas.cern.ch/$datasetDir/$htagNew/$sampleDir/$sample"  # Link to be displayed on the page
  base=$(basename ${file})
  fileType=${sample%.MxAOD*}
  oldSample=$(printf -- '%s\n' "${OldSamples[@]}" | grep "${fileType}.MxAOD" | grep "\.${sampleType}\.") # attempt to find old sample
  diffCutflowName=$(echo $sample | sed "s/h[0-9][0-9][0-9]/diff/g")
  
  # simple way to make a lot of html files (one for each sample, so >300)
  echo '<html>'                                             >pages/${sample}.php  # rewrite file if old file exists 
  echo '<html lang="en">'                                  >>pages/${sample}.php  # append to file we just created
  echo '<head>'                                            >>pages/${sample}.php  
  echo ' <meta charset="utf-8" />'                         >>pages/${sample}.php  # not going to explain html, look it up, it sucks
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
  echo '<td><p>'$htagNew'</p></td>'                        >>pages/${sample}.php
  echo '<td><p>'$htagOld'</p></td>'                        >>pages/${sample}.php
  echo '<td><p>'difference'</p></td>'                      >>pages/${sample}.php
  echo '</tr>'                                             >>pages/${sample}.php
  echo '<tr>'                                              >>pages/${sample}.php
  echo '<td>''<object width="484" height="300" type="text/plain" 'data=\"../AllCutflows/cutflows/${sample}.txt\"' border="0"></object>''</td>' >>pages/${sample}.php
  if [[ ! -z "$oldSample" ]]; then # case for when there is an old sample
    echo '<td>''<object width="484" height="300" type="text/plain" 'data=\"../AllCutflows/cutflows/${oldSample}.txt\"' border="0"></object>''</td>' >>pages/${sample}.php
    echo '<td>''<object width="484" height="300" type="text/plain" 'data=\"../AllCutflows/cutflows/${diffCutflowName}.txt\"' border="0"></object>''</td>' >>pages/${sample}.php
  else # there is no old sample!
    echo '<td>'"No similar sample for htag ${htagOld}!"'</td>'
    echo '<td>''</td>'
  fi
  echo '</tr>'                                             >>pages/${sample}.php
  echo '</table>'                                          >>pages/${sample}.php
 
  for var in ${VARSFORPLOTS[@]}; do # get plots from the plotter folder 

    echo '<object width="700" height="500" type="text/plain" 'data=\"../plotter/samples/${sample}/${sample}_${var}.png\"' border="0"></object>' >>pages/${sample}.php
  done
  echo '</body>'                                           >>pages/${sample}.php
  echo '</html>'                                           >>pages/${sample}.php
done 


echo ending at $(date)

