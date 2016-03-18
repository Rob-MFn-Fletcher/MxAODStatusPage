
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


eos ls $datasetDir/$htag/$mcDir/ &> MxAODs.txt
eos ls $datasetDir/$htag/$dataDir/ &>> MxAODs.txt
eos ls $datasetDir/$htag/$AllSysDir/ &>> MxAODs.txt
eos ls $datasetDir/$htag/$PhotonSysDir/ &>> MxAODs.txt

while read sample; do
  file="root://eosatlas.cern.ch/$datasetDir/$htag/$mcDir/$sample"
  base=$(basename ${file})
  fileType=${sample%.MxAOD*}
  oldSample=$(eos ls $datasetDir/$htagOld/$mcDir/ | grep "${fileType}.MxAOD")
  diffCutflowName=$(echo $oldSample | sed "s/h[0-9][0-9][0-9]/diff/g")
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
  echo '<td><p>'difference'</p></td>'                        >>pages/${sample}.php
  echo '</tr>'                                             >>pages/${sample}.php
  echo '<tr>'                                              >>pages/${sample}.php
  echo '<td>''<object width="484" height="300" type="text/plain" 'data=\"../AllCutflows/${sample}.txt\"' border="0"></object>''</td>' >>pages/${sample}.php
  echo '<td>''<object width="484" height="300" type="text/plain" 'data=\"../AllCutflows/${oldSample}.txt\"' border="0"></object>''</td>' >>pages/${sample}.php
  echo '<td>''<object width="484" height="300" type="text/plain" 'data=\"../AllCutflows/${diffCutflowName}.txt\"' border="0"></object>''</td>' >>pages/${sample}.php
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
done < "MxAODs.txt"



