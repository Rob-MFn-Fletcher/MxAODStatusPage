[[ -z "$datasetDir" ]] && source ../../setup.sh
#setupATLAS
localSetupROOT
localSetupPyAMI
[[ ! -z "$(voms-proxy-info |& grep 'not found')" ]] && voms-proxy-init -voms atlas
[[ "$(voms-proxy-info |& grep 'timeleft'| awk '{print $3}')" == '00:00:00' ]] && voms-proxy-init -voms atlas
