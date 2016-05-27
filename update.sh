# run like source update.sh NEWHTAG OLDTAG
# e.g. source update h011 h010
# need both htags in order to compare

[[ -z "$1" ]] && echo Please two htags as an argument! E.G source update.sh h011  && return
[[ -z "$datasetDir" ]] && source setup.sh

#[[ ! -d "$EOSMOUNTDIR/$datasetDir" ]] && echo "EOS failed to mount in setup script! Change lxplus machines?" && return

htagNew=$1

echo Updating for new htag: $htagNew


#echo $htagNew > CurrentHtag.txt

currentDir=$(pwd)

echo Updating Variable Lists...
cd variables
#source getFullVarList.sh $htagNew
source batchSubmitter.sh $htagNew
cd ..

echo


echo updating ALL cutflows...
cd AllCutflows
source batchSubmitter.sh $htagNew
cd ..

echo
cd samplePage
echo getting file locations...
source getFileLocations.sh $htagNew
cd ..
echo

echo Updating live search for $htagNew
cd liveSearch
source makeXMLforLiveSearch.sh $htagNew
cd ..

echo

echo updating ALL plots...
[[ ! -d plotter/outputbatch ]] && mkdir plotter/outputbatch
cd plotter/outputbatch
#source makePlots.sh $htagNew $htagOld        # for local running (takes a long time)
source ../batchSubmitter.sh $htagNew   # for lxplus batch submission (faster), sourced from output folder to avoid massive clutter since I can't figure out how to change the directory the output gets copied to.  -outdir -cwd -oo -eo etc seem to have no effect...
cd ../../

#echo 
#echo Updating File sizes...
#cd fileSize
#source getFileSize.sh $htagNew
#cd ..

echo Updated for $htag! Cutflows and Plots will be updated as the jobs finish
