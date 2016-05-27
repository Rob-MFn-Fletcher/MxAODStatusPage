[[ -z "$1" ]] && echo "NEED 1st arugment!" && return

[[ -z "$datasetDir" ]] && echo "please source the setup script" && return
#[[ ! -d outputbatch ]] && mkdir outputbatch


htagNew=$1
[[ ! -d $BASEDIR/plotter/samples/$htagNew ]] && mkdir -p $BASEDIR/plotter/samples/$htagNew

sed -i "s|^export BASEDIR=.*|export BASEDIR=${BASEDIR}|g" $BASEDIR/plotter/makePlotBatch.sh
varsStringArray=$(echo ${VARSFORPLOTS[@]} | sed "s/^/std::string___plotVars[${#VARSFORPLOTS[@]}]={\"/g" | sed 's/$/"};/g' | sed 's/ /","/g' | sed 's/___/ /g')
echo $varsStringArray > $BASEDIR/plotter/Root/plotVars.h
echo '// This file is produced automatically in makePlots.sh. To change the variables that are plotted, change the list in the variable VARSFORPLOTS in the setup script' >> $BASEDIR/plotter/Root/plotVars.h
SampleDirs=()
SampleDirs+=($(eos ls $datasetDir/$htagNew/))

Samples=()
for DIR in ${SampleDirs[@]}; do
  Samples+=($(eos ls $datasetDir/$htagNew/$DIR/ | grep .root ))
  [[ $DIR =~ data ]] && Samples+=($(eos ls $datasetDir/$htagNew/$DIR/runs/ | grep .root))
done

logFileSize=""
[[ -e $BASEDIR/plotter/submit.out ]] && logFileSize=$(ls -l $BASEDIR/plotter/submit.out | awk '{print $5}')
[[ ! -z $logFileSize ]] && [[ $logFileSize -gt 1000000  ]] && rm $BASEDIR/plotter/submit.out

fileNew=""
sampleDir=""
for DIR in ${SampleDirs[@]}; do
  [[ ! -z "$(eos ls $datasetDir/$htagNew/$DIR/$fileName 2>/dev/null)"  ]] && fileNew="$EOSMOUNTDIR/$datasetDir/$htagNew/$DIR/$fileName" && sampleDir=$DIR
  [[ ! -z "$(eos ls $datasetDir/$htagNew/$DIR/runs/$fileName 2>/dev/null)"  ]] && fileNew="$EOSMOUNTDIR/$datasetDir/$htagNew/$DIR/runs/$fileName" && sampleDir=$DIR/runs
done

echo submitting ${#Samples[@]} lxplus batch jobs for plots...
rm -r $BASEDIR/plotter/outputbatch/*
resetProgressBar

for fileName in ${Samples[@]}; do
  # generously submitted to the 1nd queue (cput time 1 day), could split up by time, size, etc. Most are finished in ~15 minutes
  bsub -q 8nh $BASEDIR/plotter/makePlotBatch.sh $fileName $htagNew  >> $BASEDIR/plotter/submit.out
  tickProgressBar ${#Samples[@]}
done
endProgressBar
