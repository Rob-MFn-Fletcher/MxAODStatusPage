BASEDIR=$1
currSample=$2
fileType=${currSample%.MxAOD*}
samples=()
for dir in $(ls $BASEDIR/plotter/samples/); do 
  samples+=($(for i in $(ls $BASEDIR/plotter/samples/$dir/ | grep "$fileType\."); do basename $i ; done;))
done
for i in ${samples[@]}; do
  echo $i
done
