# run like source getVarDiffs.sh h011 h010
# script that compares the variables in the new htag to the variables in the previous htag,
# and dumps each into a txt file that is read by the indes.php of the site


[[ -z "$1" ]] && echo "NEED 1st arugment!" && return
[[ -z "$2" ]] && echo "NEED 2nd arugment!" && return

currSample=$1
compSample=$2
BASEDIR=$3

compHtag=$(echo ${compSample} | grep -o '\.h[0-9][0-9][0-9].*\.' ) # make sure I don't get something stupid like ggh125
#echo $compHtag
compHtag=${compHtag%?}
compHtag=${compHtag#?}


currHtag=$(echo ${currSample} | grep -o '\.h[0-9][0-9][0-9].*\.')
currHtag=${currHtag%?}
currHtag=${currHtag#?}


# check if string is in array of strings.  Why the hell didn't I do this in python?
containsElement () {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}

# get the collection trees with the variable names + sed, grep, and awk magic to get clean list


varsComp=$(cat $BASEDIR/variables/htags/$compHtag/${compSample}_vars.txt | awk '{print $NF}')
varsCurr=$(cat $BASEDIR/variables/htags/$currHtag/${currSample}_vars.txt | awk '{print $NF}')

[[ -z "${varsCurr[@]}" ]] && echo "$currSample LIST IS EMPTY!!!!!!" && return
[[ -z "${varsComp[@]}" ]] && echo $compSample list is empty!!! && return
# check for variables that are in the old htag but not in the new htag
# removed vars
for i in ${varsComp[@]}; do
  containsElement $i ${varsCurr[@]} || echo $i  
done



## check for variables that are in the new htag but not in the old htag
#for i in ${varsNew[@]}; do
#  containsElement $i ${varsOld[@]} || echo $i  >> addedVars.txt
#done
