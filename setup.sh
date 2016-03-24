# global vars used in scripts
[[ ! -d eos ]] && mkdir eos
export datasetDir=/eos/atlas/atlascerngroupdisk/phys-higgs/HSG1/MxAOD
export BASEDIR=$(pwd)
export EOSMOUNTDIR=$BASEDIR
#export EOSMOUNTDIR=root://eosatlas.cern.ch/   # this is much slower!!
export MXAOD_MC_TYPES=(MxAOD MxAODAllSys MxAODPhotonSys)
export MXAOD_MC_DIRS=(mc_25ns data_25ns AllSys PhotonSys)
export MXAODTYPES=(MxAOD MxAODAllSys MxAODPhotonSys)
export MXAODDIRS=(mc_25ns data_25ns AllSys PhotonSys)
export DATANAME=physics_Main
export COLLECTION_TREE_NAME="CollectionTree"
export VARSFORPLOTS=(HGamEventInfoAuxDyn.cosTS_yy HGamEventInfoAuxDyn.cosTS_yyjj HGamEventInfoAuxDyn.Dphi_yy_jj HGamEventInfoAuxDyn.DRmin_y_j HGamEventInfoAuxDyn.DR_y_y HGamEventInfoAuxDyn.Dy_j_j HGamEventInfoAuxDyn.Dy_y_y HGamEventInfoAuxDyn.Dy_yy_jj HGamEventInfoAuxDyn.E_y1 HGamEventInfoAuxDyn.E_y2 HGamEventInfoAuxDyn.m_ee HGamEventInfoAuxDyn.met_TST HGamEventInfoAuxDyn.m_jj HGamEventInfoAuxDyn.m_mumu HGamEventInfoAuxDyn.mu HGamEventInfoAuxDyn.m_yy_hardestVertex HGamEventInfoAuxDyn.m_yy HGamEventInfoAuxDyn.m_yy_resolution HGamEventInfoAuxDyn.m_yy_zCommon HGamEventInfoAuxDyn.N_e HGamEventInfoAuxDyn.N_j HGamEventInfoAuxDyn.NLoosePhotons HGamEventInfoAuxDyn.N_mu HGamEventInfoAuxDyn.numberOfPrimaryVertices HGamEventInfoAuxDyn.phi_TST HGamEventInfoAuxDyn.pT_hard HGamEventInfoAuxDyn.pT_j1 HGamEventInfoAuxDyn.pT_j2 HGamEventInfoAuxDyn.pT_jj HGamEventInfoAuxDyn.pTt_yy HGamEventInfoAuxDyn.pT_y1 HGamEventInfoAuxDyn.pT_y2 HGamEventInfoAuxDyn.pT_yy HGamEventInfoAuxDyn.sumet_TST HGamEventInfoAuxDyn.yAbs_yy HGamEventInfoAuxDyn.Zepp)
export VARSFORCUTFLOWS=("NxAOD=0" "NDxAOD=1" "ALLEVTS=2" "DUPLICATE=3" "TRIGGER=4" "GRL=5" "DQ=6" "VERTEX=7" "TWO_LOOSE_GAM=8" "AMBIGUITY=9" "TRIG_MATCH=10" "GAM_TIGHTID=11" "GAM_ISOLATION=12" "RELPTCUTS=13" "MASSCUT=14" "PASSALL=15")


export mcDir=mc_25ns
export dataDir=data_25ns
export EXAMPLEFILE=PowhegPy8_VBF125_small # specific file type to be used for variable dumps/comparisons
[[ ! -d "$EOSMOUNTDIR/$datasetDir" ]] && output=$(eosmount eos 2>&1)
if [[ ! -d "$EOSMOUNTDIR/$datasetDir" ]]; then
  echo $output
  echo FAILED TO MOUNT EOS! Please try different lxplus machine! Some machines just seem to fail...
  return 1
fi

setupATLAS
localSetupROOT
