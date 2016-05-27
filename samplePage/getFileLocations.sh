[[ -z "$1" ]] && echo "NEED 1st arugment!" && return
echo starting at $(date)
htagNew=$1

[[ -z "$datasetDir" ]] && echo "please source the setup script" && return
[[ ! -d htags/$htagNew ]] && mkdir -p htags/$htagNew
SampleDirs=()
SampleDirs+=($(eos ls $datasetDir/$htagNew/))


outputFile=htags/$htagNew/fileLocs.txt

echo "File Location List:" > $outputFile
Samples=()
for DIR in ${SampleDirs[@]}; do
  Samples+=($(eos ls $datasetDir/$htagNew/$DIR/ | grep .root ))
  [[ $DIR =~ data ]] && Samples+=($(eos ls $datasetDir/$htagNew/$DIR/runs/ | grep .root))
done

resetProgressBar
for sample in ${Samples[@]}; do
  for DIR in ${SampleDirs[@]}; do
    [[ ! -z "$(eos ls $datasetDir/$htagNew/$DIR/$sample 2>/dev/null)"  ]] && filePath="$EOSMOUNTDIR/$datasetDir/$htagNew/$DIR/$sample" && sampleDir=$DIR
    [[ $DIR =~ data ]] && [[ ! -z "$(eos ls $datasetDir/$htagNew/$DIR/runs/$sample 2>/dev/null)"  ]] && filePath="$EOSMOUNTDIR/$datasetDir/$htagNew/$DIR/runs/$sample" && sampleDir=$DIR/runs
  done

  filePath="root://eosatlas.cern.ch/$datasetDir/$htagNew/$sampleDir/$sample"
  echo $sample $filePath >> $outputFile
  tickProgressBar ${#Samples[@]}
done 
endProgressBar



