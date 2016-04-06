[[ -z "$1" ]] && echo "NEED 1st arugment!" && return
[[ -z "$2" ]] && echo "NEED 2nd arugment!" && return

[[ -z "$EXAMPLEFILE" ]] && echo "please source the setup script" && return
[[ ! -d outputbatch ]] && mkdir outputbatch
htagNew=$1
htagOld=$2

sed -i "s|^export BASEDIR=.*|export BASEDIR=${BASEDIR}|g" $BASEDIR/plotter/makePlotBatch.sh
  varsStringArray=$(echo ${VARSFORPLOTS[@]} | sed "s/^/std::string___plotVars[${#VARSFORPLOTS[@]}]={\"/g" | sed 's/$/"};/g' | sed 's/ /","/g' | sed 's/___/ /g')
echo $varsStringArray > $BASEDIR/plotter/Root/plotVars.h
echo '// This file is produced automatically in makePlots.sh. To change the variables that are plotted, change the list in the variable VARSFORPLOTS in the setup script' >> $BASEDIR/plotter/Root/plotVars.h
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
rm -r $BASEDIR/plotter/outputbatch/*
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
  # generously submitted to the 1nd queue (cput time 1 day), could split up by time, size, etc. Most are finished in ~15 minutes
  bsub -q 1nd $BASEDIR/plotter/makePlotBatch.sh $fileName $htagNew $htagOld >> $BASEDIR/plotter/submit.out
  progress=$(echo "scale=5; $progress + 1.0/${#Samples[@]}" | bc)
done
echo
