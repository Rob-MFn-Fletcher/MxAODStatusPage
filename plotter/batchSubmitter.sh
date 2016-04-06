[[ -z "$1" ]] && echo "NEED 1st arugment!" && return
[[ -z "$2" ]] && echo "NEED 2nd arugment!" && return

[[ -z "$EXAMPLEFILE" ]] && echo "please source the setup script" && return
[[ ! -d outputbatch ]] && mkdir outputbatch
htagNew=$1
htagOld=$2

sed -i "s|^export BASEDIR=.*|export BASEDIR=${BASEDIR}|g" $BASEDIR/plotter/makePlotBatch.sh

Samples=()
for DIR in ${MXAODDIRS[@]}; do
  Samples+=($(eos ls $datasetDir/$htagNew/$DIR/ ))
  #break
done

logFileSize=$(ls -l $BASEDIR/plotter/submit.out | awk '{print $5}')
[[ ! -z $logFileSize ]] && [[ $logFileSize -gt 1000000  ]] && rm $BASEDIR/plotter/submit.out

echo submitting ${#Samples[@]} lxplus batch jobs for plots...
progress=$(( 0 ))
barWidth=$(( 70 ))
for fileName in ${Samples[@]}; do
  pos=$(echo "scale=0; $barWidth * $progress" | bc)
  posRound=$(echo "($pos + 0.5) / 1" | bc)
  echo -ne '['
  for i in $(seq 0 $barWidth); do
    if   [[ "$i" -lt "$posRound" ]]; then
      echo -ne '='
    elif [[ "$i" -eq "$posRound" ]]; then
      echo -ne '>'
    else
      echo -ne ' '
    fi
  done
  progressRound=$(echo "($progress  * 100.0 + 0.5)/1" | bc)
  echo -ne '] '$(echo "scale=0; $progressRound" | bc) " %\r"
  bsub -q 1nd $BASEDIR/plotter/makePlotBatch.sh $fileName $htagNew $htagOld >> $BASEDIR/plotter/submit.out
  progress=$(echo "scale=5; $progress + 1.0/${#Samples[@]}" | bc)
done
echo
