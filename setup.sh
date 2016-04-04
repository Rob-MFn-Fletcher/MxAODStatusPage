# global vars used in scripts
[[ ! -d eos ]] && mkdir eos
export datasetDir=/eos/atlas/atlascerngroupdisk/phys-higgs/HSG1/MxAOD # location of the MxAODs on EOS
export BASEDIR=$(pwd)                                                 # working directory
export EOSMOUNTDIR=$BASEDIR                                           # location where EOS is mounted using eosmount
#export EOSMOUNTDIR=root://eosatlas.cern.ch/                          # xrootd is much slower than using eosmount!!
export MXAOD_MC_TYPES=(MxAOD MxAODAllSys MxAODPhotonSys)              # types of MC MxAODs
export MXAOD_MC_DIRS=(mc_25ns AllSys PhotonSys)                       # folders of MC MxAODs on EOS 
export MXAODTYPES=(MxAOD MxAODAllSys MxAODPhotonSys)                  # types of MxAODs (including MC and data) 
export MXAODDIRS=(mc_25ns data_25ns AllSys PhotonSys)                 # folders of MxAODs (including MC and data)
export mcDir=mc_25ns                                                  # regular MC directory
export dataDir=data_25ns                                              # data directory
export DATANAME=physics_Main                                          # unique identifier for data files
export COLLECTION_TREE_NAME="CollectionTree"                          # tree where kinematic variables are located in MxAOD
export EXAMPLEFILE=PowhegPy8_VBF125_small                             # file used for variable dumps/comparisons and file size

# Variables to be plotted
export VARSFORPLOTS=(HGamEventInfoAuxDyn.cosTS_yy HGamEventInfoAuxDyn.cosTS_yyjj HGamEventInfoAuxDyn.Dphi_yy_jj HGamEventInfoAuxDyn.DRmin_y_j HGamEventInfoAuxDyn.DR_y_y HGamEventInfoAuxDyn.Dy_j_j HGamEventInfoAuxDyn.Dy_y_y HGamEventInfoAuxDyn.Dy_yy_jj HGamEventInfoAuxDyn.E_y1 HGamEventInfoAuxDyn.E_y2 HGamEventInfoAuxDyn.m_ee HGamEventInfoAuxDyn.met_TST HGamEventInfoAuxDyn.m_jj HGamEventInfoAuxDyn.m_mumu HGamEventInfoAuxDyn.mu HGamEventInfoAuxDyn.m_yy_hardestVertex HGamEventInfoAuxDyn.m_yy HGamEventInfoAuxDyn.m_yy_resolution HGamEventInfoAuxDyn.m_yy_zCommon HGamEventInfoAuxDyn.N_e HGamEventInfoAuxDyn.N_j HGamEventInfoAuxDyn.NLoosePhotons HGamEventInfoAuxDyn.N_mu HGamEventInfoAuxDyn.numberOfPrimaryVertices HGamEventInfoAuxDyn.phi_TST HGamEventInfoAuxDyn.pT_hard HGamEventInfoAuxDyn.pT_j1 HGamEventInfoAuxDyn.pT_j2 HGamEventInfoAuxDyn.pT_jj HGamEventInfoAuxDyn.pTt_yy HGamEventInfoAuxDyn.pT_y1 HGamEventInfoAuxDyn.pT_y2 HGamEventInfoAuxDyn.pT_yy HGamEventInfoAuxDyn.sumet_TST HGamEventInfoAuxDyn.yAbs_yy HGamEventInfoAuxDyn.Zepp)

# Variables for outputing the cutflows.  Only ALLEVTS is used in the code, code is copied from HGamTools
export VARSFORCUTFLOWS=("NxAOD=0" "NDxAOD=1" "ALLEVTS=2" "DUPLICATE=3" "TRIGGER=4" "GRL=5" "DQ=6" "VERTEX=7" "TWO_LOOSE_GAM=8" "AMBIGUITY=9" "TRIG_MATCH=10" "GAM_TIGHTID=11" "GAM_ISOLATION=12" "RELPTCUTS=13" "MASSCUT=14" "PASSALL=15")


[[ ! -d "$EOSMOUNTDIR/$datasetDir" ]] && output=$(eosmount eos 2>&1)
if [[ ! -d "$EOSMOUNTDIR/$datasetDir" ]]; then
  echo $output
  echo FAILED TO MOUNT EOS! Please try different lxplus machine! Some machines just seem to fail...
  return 1
fi

setupATLAS
localSetupROOT # used for plotting variables
asetup AthAnalysisBase,2.1.30,here # used for checking file size
