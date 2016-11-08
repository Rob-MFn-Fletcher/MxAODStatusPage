# script to get the cutflows all of the MxAODs in a release (e.g. h011).  Meant to run on lxplus batch system. Called by batchSubmitter.sh in this folder.
# Creates the txt files with cutflows and then copies them to the samples/HTAG/ directory

[[ -z "$1" ]] && echo "NEED 1st arugment! FILENAME e.g. mc15c.PowhegPy8_ggH750.MxAOD.p2616.h012.root" && exit 1
[[ -z "$2" ]] && echo "NEED 2nd arugment! newHtag e.g. h011" && exit 1
# This base dir is automatically set by batchSubmitter, changing it will do nothing since it will be reset
export BASEDIR=/afs/cern.ch/user/h/hgamma/www

# need to setup EOS
source /afs/cern.ch/project/eos/installation/atlas/etc/setup.sh

# need to setup common site variables
source $BASEDIR/setup.sh

echo started $0 at $(date)
fileName=$1
htagNew=$2

[[ -z "$datasetDir" ]] && echo Please source the setup script!! && exit
[[ ! -d cutflows/$htagNew ]] && mkdir -p cutflows/$htagNew

SampleDirs=()
SampleDirs+=($(eos ls $datasetDir/$htagNew/))

#Samples=()
#for DIR in ${SampleDirs[@]}; do
#  Samples+=($(eos ls $datasetDir/$htagNew/$DIR/ | grep .root ))
#  [[ $DIR =~ data ]] && Samples+=($(eos ls $datasetDir/$htagNew/$DIR/runs/ | grep .root))
#done

echo "Making Cutflows for all samples on EOS for $htagNew..."

file=""
# clunky way to get sample dir since bash doesn't like 2d arrays
for DIR in ${SampleDirs[@]}; do
  [[ ! -z "$(eos ls $datasetDir/$htagNew/$DIR/$fileName 2>/dev/null)"  ]] && file="$EOSMOUNTDIR/$datasetDir/$htagNew/$DIR/$fileName" && sampleDir=$DIR
  [[ ! -z "$(eos ls $datasetDir/$htagNew/$DIR/runs/$fileName 2>/dev/null)"  ]] && file="$EOSMOUNTDIR/$datasetDir/$htagNew/$DIR/runs/$fileName" && sampleDir=$DIR/runs
done
echo $file
base=$(basename ${file})
fileType=${fileName%.MxAOD*}
fileType=$(echo $fileType | sed 's/mc.*\.//g')
cutFlowName=CutFlow_$fileType

# get number of files in the sample.  This is to handle samples that are split across many files, such as large AllSys samples
nFiles=$(eos ls $datasetDir/$htagNew/$sampleDir/$fileName | wc -l)
if [[ $fileName =~ ^data ]]; then
  root -l -q -b "$BASEDIR/AllCutflows/printCutflowData.c(\"${file}\")" 2>err.log 1> cutflows/$htagNew/${fileName}.txt
  #root -l -q -b "$BASEDIR/AllCutflows/printCutflowData.c(\"${file}\")"
else
  root -l -q -b "$BASEDIR/AllCutflows/printCutflow.c(\"${file}\",${nFiles},\"${cutFlowName}\")"  2>err.log 1> cutflows/$htagNew/${fileName}.txt
  #root -l -q -b "$BASEDIR/AllCutflows/printCutflow.c(\"${file}\",${nFiles},\"${cutFlowName}\")"
fi
# lets format the cutflow nicely...
sed -i'.og' "1d" cutflows/$htagNew/${fileName}.txt
sed -i'.og' "s/^ *//g" cutflows/$htagNew/${fileName}.txt
sed -i'.og' "s/Processing.*/                    $fileType/g" cutflows/$htagNew/${fileName}.txt
cp cutflows/$htagNew/${fileName}.txt $BASEDIR/AllCutflows/cutflows/$htagNew/ # copy from lxplus batch node to website folder

