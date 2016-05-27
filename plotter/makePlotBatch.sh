[[ -z "$1" ]] && echo "NEED 1st arugment! SampleName e.g. PowhegPy8_ggH125_small.MxAOD.p2421.h011.root" && exit 1
[[ -z "$2" ]] && echo "NEED 2nd arugment! newHtag e.g. h011" && exit 1
# This base dir is automatically set by batchSubmitter, changing it will do nothing since it will be reset
export BASEDIR=/afs/cern.ch/user/a/athompso/www
fileName=$1
htagNew=$2
source /afs/cern.ch/project/eos/installation/atlas/etc/setup.sh
source $BASEDIR/setup.sh

#source $BASEDIR/plotter/makePlotSingle.sh $fileName $htagNew $htagOld

[[ -z "$datasetDir" ]] && echo "please source the setup script" && exit 1
[[ ! -d samples ]] && mkdir samples
[[ ! -d samples/$htagNew ]] && mkdir samples/$htagNew


echo starting plots loop at $(date)
echo

[[ -e "err.log" ]] && rm err.log
SampleDirs=()
SampleDirs+=($(eos ls $datasetDir/$htagNew/))
fileNew=""
sampleDir=""
for DIR in ${SampleDirs[@]}; do
  [[ ! -z "$(eos ls $datasetDir/$htagNew/$DIR/$fileName 2>/dev/null)"  ]] && fileNew="$EOSMOUNTDIR/$datasetDir/$htagNew/$DIR/$fileName" && sampleDir=$DIR
  [[ ! -z "$(eos ls $datasetDir/$htagNew/$DIR/runs/$fileName 2>/dev/null)"  ]] && fileNew="$EOSMOUNTDIR/$datasetDir/$htagNew/$DIR/runs/$fileName" && sampleDir=$DIR/runs
done


fileType=${fileName%.MxAOD*}

echo running on sample: $fileName

# need to make folder for plots if it is a new sample (root won't create the folder)
#[[ ! -d "samples/$fileName" ]] && mkdir -p samples/$fileName
#varsStringArray=$(echo ${VARSFORPLOTS[@]} | sed 's/^/{\\"/g' | sed 's/$/\\"}/g' | sed 's/ /\\",\\"/g') 
varsStringArray=$(echo ${VARSFORPLOTS[@]} | sed "s/^/std::string___plotVars[${#VARSFORPLOTS[@]}]={\"/g" | sed 's/$/"};/g' | sed 's/ /","/g' | sed 's/___/ /g')
#echo $varsStringArray > Root/plotVars.h
#echo '// This file is produced automatically in makePlots.sh. To change the variables that are plotted, change the list in the variable VARSFORPLOTS in the setup script' >> Root/plotVars.h

nFilesNew=$(eos ls $datasetDir/$htagNew/$sampleDir/$fileName | wc -l)
root -l -b -q "$BASEDIR/plotter/Root/plotMakerConstBin.c(\"${htagNew}\",\"${fileNew}\",${nFilesNew})" 2>err.log   # lots of errors that don't matter...
#root -l -b -q "Root/plotAllVars.c(\"${fileOld}\",${nFilesOld},\"${fileNew}\",${nFilesNew})"   # lots of errors that don't matter...

cp -r samples/$htagNew/* $BASEDIR/plotter/samples/$htagNew/

#cat err.log | grep -v 'Warning in <TClass::Init>:' | grep -v 'Error in <TBranchElement::InitInfo>:' > usefulErr.log

echo
echo end of plots loop at $(date)

