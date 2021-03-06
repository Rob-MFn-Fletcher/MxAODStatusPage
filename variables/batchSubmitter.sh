# this script submits a job to the lxplus batch queue to go through each sample of a particular release
# and create a .txt file with the cutflow information.  As the job runs, these files
# are created and copied to cutflows/HTAG/FULLSAMPLENAME.txt
# usage: source batchSubmitter.sh h011


[[ -z "$1" ]] && echo "NEED 1st arugment!" && return

[[ -z "$datasetDir" ]] && echo "please source the setup script" && return
#[[ ! -d outputbatch ]] && mkdir outputbatch
#[[ ! -d htags ]] && mkdir htags
htagNew=$1
[[ ! -d htags/$htagNew ]] && mkdir -p htags/$htagNew

sed -i "s|^export BASEDIR=.*|export BASEDIR=${BASEDIR}|g" $BASEDIR/variables/getFullVarListBatch.sh


#echo ${VARSFORCUTFLOWS[@]} | sed 's/ /, /g' | sed 's/^/enum CutEnum {/g' | sed 's/$/};/g' > $BASEDIR/AllCutflows/cutflow_vars.h
#echo '// This file is automatically generated by getCutflows.sh.  To change the cutflows variables, change the setup script' >> $BASEDIR/AllCutflows/cutflow_vars.h

echo Submitting batch job for variables... This job takes 30mins-1h to finish, variables are updated as the job runs

bsub -R "swp > 10000" -R "rusage[mem=1500]" -q 8nh $BASEDIR/variables/getFullVarListBatch.sh $htagNew
