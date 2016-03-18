# run like source dumpVars h011
# script that compares the variables in the new htag to the variables in the previous htag,
# and dumps each into a txt file that is read by the indes.php of the site


[[ -z "$1" ]] && echo "NEED 1st arugment!" && return

#datasetDir=/eos/atlas/atlascerngroupdisk/phys-higgs/HSG1/MxAOD
htagNew=$1
num=${htagNew:1}
num=$(echo $num | sed "s/^0*//g")
htagPrevNum=$(($num - 1))
htagPrevNum=$(printf %03d $htagPrevNum)
htagOld=h$htagPrevNum



inputFileType=PowhegPy8_VBF125_small


inputFileOld=$(eos ls $datasetDir/$htagOld/$mcDir/ | grep $inputFileType)
inputFileNew=$(eos ls $datasetDir/$htagNew/$mcDir/ | grep $inputFileType)

# check if string is in array of strings.  Why the hell didn't I do this in python?
containsElement () {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}

# get the collection trees with the variable names + sed, grep, and awk magic to get clean list

varsOld=($(echo "CollectionTree->Print()" | root -l root://eosatlas.cern.ch/$datasetDir/$htagOld/$mcDir/$inputFileOld \
   | grep "Br " | awk '{print $3}' | sed 's/://g' ))
[[ -z "${varsOld[@]}" ]] && echo CHECK INPUT FILE!!!!!! &&return

varsNew=($(echo "CollectionTree->Print()" | root -l root://eosatlas.cern.ch/$datasetDir/$htagNew/$mcDir/$inputFileNew \
   | grep "Br " | awk '{print $3}' | sed 's/://g' ))
[[ -z "${varsNew[@]}" ]] && echo CHECK INPUT FILE!!!!!! &&return

[[ "${varsOld[@]}" == "${varsNew[@]}" ]] && echo variable lists are the same! That seems unlikely Check inputs? 


[[ -e removedVars.txt ]] && rm removedVars.txt 
# check for variables that are in the old htag but not in the new htag
for i in ${varsOld[@]}; do
  containsElement $i ${varsNew[@]} || echo $i  >> removedVars.txt
done



[[ -e addedVars.txt ]] && rm addedVars.txt 
# check for variables that are in the new htag but not in the old htag
for i in ${varsNew[@]}; do
  containsElement $i ${varsOld[@]} || echo $i  >> addedVars.txt
done
