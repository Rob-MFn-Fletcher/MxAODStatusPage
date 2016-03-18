# gets the full list of variables from a root file, and puts them in a nice format
# of TYPE    VAR,    quite ugly


[[ -z "$1" ]] && echo "NEED 1st arugment! htag" && return

#datasetDir=/eos/atlas/atlascerngroupdisk/phys-higgs/HSG1/MxAOD
htagNew=$1
inputFileType=PowhegPy8_VBF125_small
mcDir=mc_25ns

inputFileNew=$(eos ls $datasetDir/$htagNew/$mcDir/ | grep $inputFileType)

echo $inputFileNew

# take a look at CollectionTree->Print() for an MxAOD for this to make more sense:

# Massive bash command incoming.  First greps make a nice list, then sed command (unsigned)
# makes it so that the variable type doesn't get broken up, the massive AWK command does
# the heavy lifting of fixing the root output when the variable type gets split across
# 2 lines.  The getline commands (how the next line is gotten in awk) are strange,
# and this is the only way I got them to
# work properly.  Getline returns 1 so I remove these weird 1's with sed, fix the leading
# ":" on some variables, sort by variable names, then correct the shortened variable types
# of F, B, i, I, l.  I then columnize the two columns and return the unsigned variables
# to their proper name.

echo "CollectionTree->Print()" | root -l root://eosatlas.cern.ch/$datasetDir/$htagNew/$mcDir/$inputFileNew | \
    grep -A 1 "Br " | grep -v "Entries" |  grep -v "\-\-" | sed 's/unsigned /unsigned_/g' | \
    awk '{
             if ($5 ~ /:$/)               # find when xAOD:: variables are split across line
                 print $3, $5 ,getline, $3;
             else if ( $5 !~ /\*/)        # normal case, 1 inserted to match getline output
                 print $3 ,1, $5 ;
             else if ($5 ~ /\*/)          # case when variable might be split
             {
                 if ($5 == "\*")          # case where entire type is on next line
                     print $3, getline, $3;
                 else if ($5 ~ /i\*/ || $5 ~ /F\*/ || $5 ~/I\*/ || $5 ~/B\*/) # refers to pointer, var not split
                     print $3, 1, $5;
                 else                     # var is split!
                     print $3 , $5, getline,$3
             }
         }' | sed 's/\* 1 //g' | sed 's/ 1 / /g' | sed 's/: :/::/g' | \
         sed 's/^://g' | sort | awk '{print $2,$1}' | sed 's/^.*\/F/Float_t/g' | \
         sed 's/^.*\/I/Int_t/g' | sed 's/^.*\/B/Bool_t/g' | sed 's/^.*\/i/int/g'| \
         sed 's/^.*\/l/long/g'  | column -t | sed 's/unsigned_/unsigned /g' > allVars.txt

#cat out.out | column -t > out1.out
#
#sed -i'.og' 's/^.*\/F/Float_t/g' out1.out
#sed -i'.og' 's/^.*\/I/Int_t/g' out1.out
#sed -i'.og' 's/^.*\/B/Bool_t/g' out1.out
#sed -i'.og' 's/^.*\/i/int/g' out1.out
#sed -i'.og' 's/^.*\/l/long/g' out1.out
#
#
#cat out1.out | column -t > allVars.txt
#rm out.out*
#rm out1.out*
