# global vars used in scripts

export datasetDir=/eos/atlas/atlascerngroupdisk/phys-higgs/HSG1/MxAOD # location of the MxAODs on EOS

# should also set BASEDIR in html/vars.php for correct website working
export BASEDIR=/afs/cern.ch/user/h/hgamma/www                      # working directory, have to hard code for lxplus batch code
[[ ! -d $BASEDIR/tmp ]] && mkdir $BASEDIR/tmp

export EOSMOUNTDIR=root://eosatlas.cern.ch/                          # xrootd is much slower than using eosmount, but more reliable for lxplus batch
#export COLLECTION_TREE_NAME="CollectionTree"                          # tree where kinematic variables are located in MxAOD (Not implemented...)

# Variables to be plotted and compared between samples
export VARSFORPLOTS=(HGamEventInfoAuxDyn.E_y1 HGamEventInfoAuxDyn.E_y2 HGamEventInfoAuxDyn.met_TST HGamEventInfoAuxDyn.m_jj HGamEventInfoAuxDyn.m_yy HGamEventInfoAuxDyn.m_yy_zCommon HGamEventInfoAuxDyn.pT_hard HGamEventInfoAuxDyn.pT_j1 HGamEventInfoAuxDyn.pT_j2 HGamEventInfoAuxDyn.pT_jj HGamEventInfoAuxDyn.pTt_yy HGamEventInfoAuxDyn.pT_y1 HGamEventInfoAuxDyn.pT_y2 HGamEventInfoAuxDyn.pT_yy HGamEventInfoAuxDyn.sumet_TST HGamPhotonsAuxDyn.ptcone20 HGamPhotonsAuxDyn.topoetcone20)

# Variables for outputing the cutflows.  Only ALLEVTS is used in the code, code is copied from HGamTools
export VARSFORCUTFLOWS=("NxAOD=0" "NDxAOD=1" "ALLEVTS=2" "DUPLICATE=3" "GRL=4" "TRIGGER=5" "DQ=6" "VERTEX=7" "TWO_LOOSE_GAM=8" "AMBIGUITY=9" "TRIG_MATCH=10" "GAM_TIGHTID=11" "GAM_ISOLATION=12" "RELPTCUTS=13" "MASSCUT=14" "PASSALL=15")
export PRESELECTION_NUM=10 # +1 from AMIBIGUITY above because of overflowbin, used in sample validation scripts
#export ALLEVENTS_NUM=3     # +1 from ALLEVTS above because of overflowbin


ATLAS_LOCAL_ROOT_BASE=/cvmfs/atlas.cern.ch/repo/ATLASLocalRootBase
source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh
localSetupROOT # used for plotting variables

#functions : 
progress=$(( 0 ))
tickProgressBar() {
  barWidth=$(( 70 ))
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
  progressRound=$(echo "($progress * 100  + 0.5)/1" | bc) 
  echo -ne '] '$(echo "scale=0; $progressRound" | bc) " %\r"
  progress=$(echo "scale=5; $progress + 1.0/$1" | bc)
}
endProgressBar() {
  barWidth=$(( 70 ))
  pos=$(echo "scale=0; $barWidth * 100" | bc)
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
  progressRound=$(echo "(100  + 0.5)/1" | bc) 
  echo -ne '] '$(echo "scale=0; $progressRound" | bc) " %\r"
  echo
}
resetProgressBar() {
  progress=$(( 0 ))
  progressRound=$(( 0 ))
}


