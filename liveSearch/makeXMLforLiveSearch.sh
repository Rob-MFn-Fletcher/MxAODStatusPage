[[ -z "$datasetDir" ]] && echo Please source the setup script!! && return


htag=$1
[[ -z "$1" ]] && echo Please one htag as an argument! && return
[[ ! -d htags ]] && mkdir htags
[[ ! -d htags/$htag ]] && mkdir htags/$htag
#cp livesearch.php htags/$htag/

SampleDirs=()
SampleDirs+=($(eos ls $datasetDir/$htag/))

MxAODList=htags/$htag/MxAODs.xml

Samples=()
for DIR in ${SampleDirs[@]}; do
  Samples+=($(eos ls $datasetDir/$htag/$DIR/ ))
  [[ $DIR =~ data ]] && Samples+=($(eos ls $datasetDir/$htag/$DIR/runs/ | grep .root))
done


echo '<?xml version="1.0" encoding="utf-8"?>' >$MxAODList
echo '<pages>' >> $MxAODList

#while read sample; do
for sample in ${Samples[@]}; do
  [[ ! "$sample" =~ .root ]] && continue
  link=""
  
  echo '<link>'              >> $MxAODList
  echo '<title>'$sample'</title>' >> $MxAODList
  echo '<url>''samplePage/samplePage.php?&amp;h='$htag'&amp;s='${sample}'</url>' >> $MxAODList
  echo '</link>'             >> $MxAODList


done
#done < "MxAODs.txt"

echo '</pages>' >> $MxAODList



