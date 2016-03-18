# run like source update.sh h011

[[ -z "$1" ]] && echo Please enter an htag as and argument! E.G source update.sh h011 && return
# May need to change these in the future
export datasetDir=/eos/atlas/atlascerngroupdisk/phys-higgs/HSG1/MxAOD
export MXAODTYPES=(MxAOD data AllSys PhotonSys)
export MXAODDIRS=(mc_25ns data_25ns AllSys PhotonSys)
export mcDir=mc_25ns
export dataDir=data_25ns
export AllSysDir=AllSys 
export PhotonSysDir=PhotonSys 
htag=$1

echo $htag > CurrentHtag.txt

currentDir=$(pwd)
echo Updating Cutflows...
cd cutflows
source getCutflows.sh $htag
cd ..

echo Updating Variable Lists...
cd variables
source getVarDiffs.sh $htag
source getFullVarList.sh $htag
cd ..

echo Updating File sizes...
cd fileSize
source getFileSize.sh $htag
cd ..


echo Updated for $htag!
