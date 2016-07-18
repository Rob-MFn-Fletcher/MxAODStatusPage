# lololololololol this same script was 60 lines long in python and didn't work files with different cuts. BASH4EVER 
#
# This script takes two files formatted in the following way:
#                 PowhegPy8_ggH125_small
# Event selection            Nevents    Cut rej.   Tot. eff.
# #it{N}_{xAOD}             95000.00      -0.00%     100.00%
# #it{N}_{DxAOD}            95000.00      -0.00%     100.00%
# All events                95000.00      -0.00%     100.00%
# No duplicates             95000.00      -0.00%     100.00%
# Pass trigger              56605.00     -40.42%      59.58%
# GRL                       56605.00      -0.00%      59.58%
# Detector DQ               56605.00      -0.00%      59.58%
# Has PV                    56605.00      -0.00%      59.58%
# 2 loose photons           47675.00     -15.78%      50.18%
# e-#gamma ambiguity        47289.00      -0.81%      49.78%
# Trigger match             46872.00      -0.88%      49.34%
# tight ID                  40469.00     -13.66%      42.60%
# isolation                 35439.00     -12.43%      37.30%
# rel. #it{p}_{T} cuts      32926.00      -7.09%      34.66%
# m_yy #in [105,160] GeV    32918.00      -0.02%      34.65%
#
# and compares them cut-by-cut

file1=$1
file2=$2

cuts=$(tail -n +3 $file1 | sed 's/\(\S\) \(\S\)/\1_\2/g' | awk '{print $1}')

if [[ ! "$(cat $file1 | wc -l)" -eq "$(cat $file2 | wc -l)" ]]; then
  echo "warning! files have different cuts.  Comparing similar cuts..."
fi
printf '%-26s %-14s %s \n' 'Event Selection' 'Absolute Diff' 'Percent Diff'
for cut in ${cuts[@]}; do 
  file1CutValue=$(cat $file1 | sed 's/\(\S\) \(\S\)/\1_\2/g' | grep -F $cut |  awk '{print $(NF-2)}')
  file2CutValue=$(cat $file2 | sed 's/\(\S\) \(\S\)/\1_\2/g' | grep -F $cut | awk '{print $(NF-2)}')
  #echo Cut: $cut File1Cut: $file1CutValue File2Cut: $file2CutValue
  #echo Searched for $cut in 
  #cat $file1 | sed 's/\(\S\) \(\S\)/\1_\2/g'
  
  [[ -z "$file2CutValue" ]] && continue
  absDiff=$(echo "scale=0; $file1CutValue - $file2CutValue" | bc)

  percentDiffNum=$(echo "scale=0; $file1CutValue - $file2CutValue" | bc)
  percentDiffDenom=$(echo "scale=0; 0.50 * ( $file1CutValue + $file2CutValue )" | bc)
  percentDiffVal=0
  if [[ ! $percentDiffDenom == 0 ]]; then 
    percentDiffVal=$(echo "scale=5; $percentDiffNum/$percentDiffDenom" | bc)
  fi

  printf '%-26s %-14.2f %f %%\n' $cut $absDiff $percentDiffVal
done
