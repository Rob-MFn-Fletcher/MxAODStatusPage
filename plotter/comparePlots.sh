#BASEDIR=/afs/cern.ch/user/a/athompso/www
source /afs/cern.ch/sw/lcg/app/releases/ROOT-externals/ROOT-latest/x86_64-slc6-gcc48-opt/setup.sh
source /afs/cern.ch/sw/lcg/app/releases/ROOT/6.06.04/x86_64-slc6-gcc48-opt/root/bin/thisroot.sh
export DISPLAY=localhost:0.0
#root -l -b -q '/afs/cern.ch/user/a/athompso/www/plotter/Root/plotCompare.c("/afs/cern.ch/user/a/athompso/www/plotter/samples/h011/Pythia8_WH80.MxAOD.p2421.h011.root","h011","/afs/cern.ch/user/a/athompso/www/plotter/samples/h010/Pythia8_WH80.MxAOD.p2421.h010.root","h010")'

BASEDIR=$1
currSample=$2
compSample=$3
compHtag=$(echo $compSample | grep -o '\.h[0-9][0-9][0-9].*\.' ) # make sure I don't get something stupid like ggh125
compHtag=${compHtag%?}
compHtag=${compHtag#?}


currHtag=$(echo $currSample | grep -o '\.h[0-9][0-9][0-9].*\.')
currHtag=${currHtag%?}
currHtag=${currHtag#?}


fileType=${currSample%.MxAOD*}

compSample=$BASEDIR/plotter/samples/$compHtag/$compSample

#tempFolderSize=""
#[[ -d $BASEDIR/tmp/ ]] && tempFolderSize=$(du -s $BASEDIR/tmp | awk '{print $1}')
#[[ ! -z $tempFolderSize ]] && [[ $tempFolderSize -gt 2000  ]] && rm $BASEDIR/tmp/*

root -l -b -q "$BASEDIR/plotter/Root/plotCompare.c(\"$BASEDIR/plotter/samples/$currHtag/${currSample}\",\"${currHtag}\",\"${compSample}\",\"${compHtag}\")"

