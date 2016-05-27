# this script submits a job to the lxplus batch queue to go through each sample of a particular release
# and create a .txt file with the cutflow information.  As the job runs, these files
# are created and copied to cutflows/HTAG/FULLSAMPLENAME.txt
# usage: source batchSubmitter.sh h011


[[ -z "$1" ]] && echo "NEED 1st arugment!" && return

[[ -z "$datasetDir" ]] && echo "please source the setup script" && return
[[ ! -d outputbatch ]] && mkdir outputbatch
htagNew=$1
[[ ! -d cutflows/$htagNew ]] && mkdir -p cutflows/$htagNew

sed -i "s|^export BASEDIR=.*|export BASEDIR=${BASEDIR}|g" $BASEDIR/AllCutflows/getCutflowsBatch.sh


echo ${VARSFORCUTFLOWS[@]} | sed 's/ /, /g' | sed 's/^/enum CutEnum {/g' | sed 's/$/};/g' > $BASEDIR/AllCutflows/cutflow_vars.h
echo '// This file is automatically generated by getCutflows.sh.  To change the cutflows variables, change the setup script' >> $BASEDIR/AllCutflows/cutflow_vars.h

echo Submitting batch job for cutflows... This job takes 30mins-1h to finish, cutflows are updated as the job runs

bsub -q 1nd $BASEDIR/AllCutflows/getCutflowsBatch.sh $htagNew
