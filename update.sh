# run like source update.sh NEWHTAG OLDTAG
# e.g. source update h011 h010
# need both htags in order to compare

[[ -z "$1" ]] && echo Please two htags as an argument! E.G source update.sh h011 h010 && return
[[ -z "$2" ]] && echo Please another htag as an argument! E.G source update.sh h011 h010 && return
source setup.sh

[[ ! -d "$EOSMOUNTDIR/$datasetDir" ]] && echo "EOS failed to mount in setup script! Change lxplus machines?" && return

htagNew=$1
htagOld=$2

echo Updating for new htag: $htagNew
echo Comparing to old htag: $htagOld


echo $htagNew > CurrentHtag.txt

currentDir=$(pwd)
echo Updating Front Page Cutflows...
cd cutflows
source getCutflows.sh $htagNew
cd ..

echo Updating Variable Lists...
cd variables
source getVarDiffs.sh $htagNew $htagOld
source getFullVarList.sh $htagNew
cd ..

echo Updating File sizes...
cd fileSize
source getFileSize.sh $htagNew
cd ..

echo updating ALL cutflows
cd AllCutflows
source getCutflows.sh $htagNew $htagOld
cd ..

echo Making webpages for ALL samples...
source makePages $htagNew $htagOld

echo Updating live search for $htagNew
cd liveSearch
source makeXMLforLiveSearch.sh $htagNew
cd ..

echo updating ALL plots.  This will take a long time...
cd plotter
source makePlots.sh $htagNew $htagOld
cd ..



echo Updated for $htag!
