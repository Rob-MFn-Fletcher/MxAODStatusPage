htag=$1
[[ -z "$1" ]] && echo Please one htag as an argument! && return

Samples=()
for DIR in ${MXAODDIRS[@]}; do
  Samples+=($(eos ls $datasetDir/$htag/$DIR/ ))
done

rootLink=root://eosatlas.cern.ch/$datasetDir/$htag


echo '<?xml version="1.0" encoding="utf-8"?>' >MxAODs.xml
echo '<pages>' >> MxAODs.xml

#while read sample; do
for sample in ${Samples[@]}; do
  [[ ! "$sample" =~ .root ]] && continue
  link=""
  if [[ "$sample" =~ AllSys ]]; then
    link=$rootLink/$AllSysDir/$sample
  elif [[ "$sample" =~ PhotonSys ]]; then
    link=$rootLink/$PhotonSysDir/$sample
  elif [[ "$sample" =~ data ]]; then
    link=$rootLink/$dataDir/$sample
  else
    link=$rootLink/$mcDir/$sample
  fi
  
  echo '<link>'              >> MxAODs.xml
  echo '<title>'$sample'</title>' >> MxAODs.xml
  #echo '<url>'$link'</url>' >> MxAODs.xml
  echo '<url>'pages/${sample}.php'</url>' >> MxAODs.xml
  echo '</link>'             >> MxAODs.xml


done
#done < "MxAODs.txt"

echo '</pages>' >> MxAODs.xml



