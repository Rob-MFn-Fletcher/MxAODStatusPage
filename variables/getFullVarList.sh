# gets the full list of variables from a root file, and puts them in a nice format
# of TYPE    VAR,    quite ugly


[[ -z "$1" ]] && echo "NEED 1st arugment! htag" && return

htagNew=$1
[[ -z "$EXAMPLEFILE" ]] && echo "please source the setup script" && return
#inputFileType=PowhegPy8_VBF125_small
inputFileType=$EXAMPLEFILE

#mcDir=mc_25ns

inputFileNew=$(eos ls $datasetDir/$htagNew/$mcDir/ | grep $inputFileType)

echo $inputFileNew

# take a look at CollectionTree->Print() for an MxAOD first for this to make more sense:
# Here is an example:
# *............................................................................*
# *Br  253 :HGamTruthElectronsAuxDyn.e : vector<float>                         *
# *Entries :    47289 : Total  Size=     695204 bytes  File Size  =     124181 *
# *Baskets :      236 : Basket Size=      32000 bytes  Compression=   5.56     *
# *............................................................................*
# *Br  254 :HGamTruthElectronsAuxDyn.m : vector<float>                         *
# *Entries :    47289 : Total  Size=     695204 bytes  File Size  =     122890 *
# *Baskets :      236 : Basket Size=      32000 bytes  Compression=   5.62     *
# *............................................................................*
# *Br  255 :HGamTruthElectronsAuxDyn.recoLink :                                *
# *         | vector<ElementLink<DataVector<xAOD::IParticle> > >               * CASES LIKE THIS MAKE IT HARDER
# *Entries :    47289 : Total  Size=     982478 bytes  File Size  =     107786 *
# *Baskets :      236 : Basket Size=      32000 bytes  Compression=   9.07     *
# *............................................................................*





# Massive bash command incoming.  First greps make a nice list, then sed command (unsigned)
# makes it so that the variable type doesn't get broken up, the massive AWK command does
# the heavy lifting of fixing the root output when the variable type gets split across
# 2 lines.  The getline commands (how the next line is gotten in awk) are strange,
# and this is the only way I got them to
# work properly.  Getline returns 1 so I remove these weird 1's with sed, fix the leading
# ":" on some variables, sort by variable names, then correct the shortened variable types
# of F, B, i, I, l.  I then columnize the two columns and return the unsigned variables
# to their proper name.

echo "CollectionTree->Print()" | root -l root://eosatlas.cern.ch/$datasetDir/$htagNew/$mcDir/$inputFileNew 2> err.log | \
    grep -A 1 "Br " | grep -v "Entries" |  grep -v "\-\-" | sed 's/unsigned /unsigned_/g' | sed 's/> > >/>_>_>/g' | \
    sed 's/> >/>_>/g' | awk '{
             if ($5 ~ /:$/)               # find when xAOD:: variables are split across line
                 print $3, $5 ,getline, $3;
             else if ( $5 !~ /\*/)        # normal case, 1 inserted to match getline output
                 print $3 ,1, $5 ;
             else if ($5 ~ /\*/)          # case when variable might be split
             {
                 if ($5 == "*")          # case where entire type is on next line
                     print $3, getline, $3;
                 else if ($5 ~ /i\*/ || $5 ~ /F\*/ || $5 ~/I\*/ || $5 ~/B\*/) # refers to pointer, var not split
                     print $3, 1, $5;
                 else                     # var is split!
                     print $3 , $5, getline,$3
             }
         }' | sed 's/\* 1 //g'  | sed 's/ 1 / /g'         | sed 's/: :/::/g' | \
         sed 's/^://g' | sort   | awk '{print $2,$1}'     | sed 's/^.*\/F/Float_t/g' | \
         sed 's/^.*\/I/Int_t/g' | sed 's/^.*\/B/Bool_t/g' | sed 's/^.*\/i/int/g'| \
         sed 's/^.*\/l/long/g'  | column -t | sed 's/unsigned_/unsigned /g' | \
         sed 's/>_>_>/> > >/g'  | sed 's/>_>/> >/g' > allVars.txt

