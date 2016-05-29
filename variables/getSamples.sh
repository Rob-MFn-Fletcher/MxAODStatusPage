BASEDIR=$1
currSample=$2
fileType=${currSample%.MxAOD*}
fileType=$(echo $fileType | sed 's/^mc.*\.//g')
samples=()
for dir in $(ls $BASEDIR/variables/htags/); do 
  samples+=($(for i in $(ls $BASEDIR/variables/htags/$dir/ | grep "$fileType\."); do basename $i ; done;))
done
for i in ${samples[@]}; do
  echo ${i%_vars.txt}
done
