# bash wrapper to format the output of diffCutflow.sh into HTML. This script gets the file path
# of the samples Cutflows and calls diffCutflow.sh to compare them.
# call like
# source compareCutflows.sh PowhegPy8_ggH125.MxAOD.p2421.h011.root PowhegPy8_ggH125.MxAOD.p2421.h010.root /afs/cern.ch/user/a/athompso/www
# The BASEDIR (/afs/cern.ch/user/a/athompso/www in the example) is usually passed from the base variable in the html/vars.php folder

currSample=$1
compSample=$2
BASEDIR=$3
compHtag=$(echo $compSample | grep -o '\.h[0-9][0-9][0-9].*\.' ) # make sure I don't get something stupid like ggh125
compHtag=${compHtag%?}
compHtag=${compHtag#?}


currHtag=$(echo $currSample | grep -o '\.h[0-9][0-9][0-9].*\.')
currHtag=${currHtag%?}
currHtag=${currHtag#?}
compSamplePath=$BASEDIR/AllCutflows/cutflows/$compHtag/${compSample}.txt
echo $compHtag

echo '<pre>'
cat $compSamplePath
echo '</pre>'

currSamplePath=$BASEDIR/AllCutflows/cutflows/$currHtag/${currSample}.txt
echo Comparision of $currHtag to $compHtag
echo '<pre>'

source $BASEDIR/AllCutflows/diffCutflow.sh $currSamplePath $compSamplePath #| sed 's/$/<br>/g'
echo '</pre>'
