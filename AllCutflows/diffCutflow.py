#!/usr/bin/env python
import sys,re,math
import os.path
#print sys.argv

#fileOld="PowhegPy8_ggH125_small.MxAOD.p2421.h010.root.txt"
#fileNew="PowhegPy8_ggH125_small.MxAOD.p2421.h011.root.txt"

fileOld=sys.argv[1]
fileNew=sys.argv[2]

if not os.path.exists(fileOld):
  print "File " + fileOld + " does not exist, skipping..."
  sys.exit(1)
if not os.path.exists(fileNew):
  print "File " + fileNew + " does not exist, skipping..."
  sys.exit(1)


categories=[]
absDiff=[]
percentDiff=[]

with open(fileOld,'r') as fO:  
  with open(fileNew,'r') as fN:
    fO_lines=fO.readlines()
    fN_lines=fN.readlines()
    if len(fO_lines) != len(fN_lines):
      print "file lengthes not equal!"
      print "old: " + str(len(fO_lines))
      print "new: " + str(len(fN_lines))
      print fO_lines
      print fN_lines
    for i in range(2,len(fO_lines)):
      line_O=  fO_lines[i].split("  ")
      line_O= filter(None, line_O)
      line_N=  fN_lines[i].split("  ")
      line_N= filter(None, line_N)
      oldVal = line_O[1]
      newVal = line_N[1]
      categories.append(line_O[0])
      absDiff.append(abs(float(oldVal)-float(newVal)))
      #percentDiff.append(float(math.fabs(float(oldVal)-float(newVal)))/(0.5 * (float(oldVal)+float(newVal))))
      percentDiffNum=float(math.fabs(float(oldVal)-float(newVal)))
      percentDiffDenom=(0.5 * (float(oldVal)+float(newVal)))
      percentDiffVal=0
      if percentDiffDenom != 0:
        percentDiffVal=percentDiffNum/percentDiffDenom
      percentDiff.append(percentDiffVal)
diffFile=re.sub(r'h[0-9][0-9][0-9]','diff', fileNew)

with open(diffFile,"w") as f:
  #f.write("                      " + "Difference\n")
  f.write("Event selection           Abs Diff       Abs Percent Diff\n")
  for i in range(0,len(categories)):
    f.write("%-26s %-14.2f %f %%\n" % (categories[i],absDiff[i],percentDiff[i]))


