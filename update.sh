# run like source update.sh NEW_HTAG
# e.g. source update h011 
# can also use ALL option to update for all htags on EOS

[[ -z "$1" ]] && echo Please two htags as an argument! E.G source update.sh h011  && return
[[ -z "$datasetDir" ]] && source setup.sh

#[[ ! -d "$EOSMOUNTDIR/$datasetDir" ]] && echo "EOS failed to mount in setup script! Change lxplus machines?" && return

htagNew=$1

echo Updating for new htag: $htagNew

if [[ $htagNew == ALL ]]; then
  htagNew=$(eos ls $datasetDir/ | grep ^h[0-9][0-9][0-9] | grep -v stage)
fi

for htag in ${htagNew[@]}; do
echo $htag
continue
currentDir=$(pwd)

echo Updating Variable Lists...
cd variables
#source getFullVarList.sh $htagNew
source batchSubmitter.sh $htag
cd ..

echo


echo updating ALL cutflows...
cd AllCutflows
source batchSubmitter.sh $htag
cd ..

echo
cd samplePage
echo getting file locations...
source getFileLocations.sh $htag
cd ..
echo

echo Updating live search for $htag
cd liveSearch
source makeXMLforLiveSearch.sh $htag
cd ..

echo

echo updating ALL plots...
[[ ! -d plotter/outputbatch ]] && mkdir plotter/outputbatch
cd plotter/outputbatch
#source makePlots.sh $htagNew $htagOld        # for local running (takes a long time)
source ../batchSubmitter.sh $htag   # for lxplus batch submission (faster), sourced from output folder to avoid massive clutter since I can't figure out how to change the directory the output gets copied to.  -outdir -cwd -oo -eo etc seem to have no effect...
cd ../../

#echo 
#echo Updating File sizes...
#cd fileSize
#source getFileSize.sh $htagNew
#cd ..

echo Updated for $htag! Cutflows and Plots will be updated as the jobs finish
done
