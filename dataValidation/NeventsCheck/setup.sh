[[ -z "$datasetDir" ]] && source ../../setup.sh
#setupATLAS
lsetup pyami root
[[ ! -z "$(voms-proxy-info |& grep 'not found')" ]] && voms-proxy-init -voms atlas
[[ "$(voms-proxy-info |& grep 'timeleft'| awk '{print $3}')" == '00:00:00' ]] && voms-proxy-init -voms atlas
eosmount ./eos

svn export svn+ssh://rfletche@svn.cern.ch/reps/atlasoff/PhysicsAnalysis/HiggsPhys/Run2/HGamma/xAOD/HGamTools/branches/HGamTools-00-00-51-branch/data/input/data1516_13TeV.txt ./InputFiles/data_h015.txt
svn export svn+ssh://rfletche@svn.cern.ch/reps/atlasoff/PhysicsAnalysis/HiggsPhys/Run2/HGamma/xAOD/HGamTools/branches/HGamTools-00-00-51-branch/data/input/mc15_13TeV.txt ./InputFiles/mc_h015.txt
svn export svn+ssh://rfletche@svn.cern.ch/reps/atlasoff/PhysicsAnalysis/HiggsPhys/Run2/HGamma/xAOD/HGamTools/branches/HGamTools-00-00-51-branch/data/input/PhotonSys.txt ./InputFiles/PhotonSys_h015.txt

