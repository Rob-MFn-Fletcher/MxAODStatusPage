/*
 * Dumps the cutflow of an MxAOD to stdout, code taken from HGamTools
 *
 *
 *
 * */

#include <string>
#include <cmath>
#include <vector>
#include <iostream>
#include <fstream>
#include "cutflow_vars.h"

void printCutflow(string datasetName,int Nfiles, string cutflowName) {

  TH1F * h;
  if(Nfiles == 0)
  {
    cout << "wat.  No files in this dataset: " << datasetName << endl;
    return;
  }
  if(Nfiles == 1)
  {
    TFile* f = TFile::Open(datasetName.c_str());
    h =(TH1F*)f->Get(cutflowName.c_str());
  }
  else
  {
    vector<string> files;
    for(int i = 1;i <= Nfiles; i++)
    {
      size_t found = datasetName.find_last_of("/");
      string baseFileName=datasetName.substr(found+1);
      size_t loc = baseFileName.find(".root");
      string fileNum="";
      if(i < 10)         fileNum="00"+std::to_string(i);
      else if (i < 100)  fileNum="0"+std::to_string(i);
      else               fileNum=std::to_string(i);
      // MxAODs on EOS that are folders have .00x.root instead of .root at the end
      baseFileName.replace(loc, baseFileName.length(), "."+fileNum+".root");
      string path=datasetName+"/"+baseFileName;
      files.push_back(path);
      TFile* f = TFile::Open(files[i-1].c_str());
      TH1F * temp = (TH1F*)f->Get(cutflowName.c_str());
      if(i == 1 ){ h = new TH1F(*temp); }
      else       { 
        if(h == 0)
        {
          cout << "Error! Cutflow "<< cutflowName <<" not found in file " << datasetName << " !  Check file integrity" << endl;
          return;
        }
        h->Add(temp);        
      }
    }

  }
 
 
 
 
  if(h == 0)
  {
    cout << "Error! Cutflow "<< cutflowName <<" not found in file " << datasetName << " !  Check file integrity" << endl;
    return;
  }
  int Ndecimals=2;
  TString format("  %-24s%10."); format+=Ndecimals; format+="f%11.2f%%%11.2f%%\n";
  int all_bin = h->FindBin(ALLEVTS);
  printf("  %-24s%10s%12s%12s\n","Event selection","Nevents","Cut rej.","Tot. eff.");
  for (int bin=1;bin<=h->GetNbinsX();++bin) {
    double ntot=h->GetBinContent(all_bin), n=h->GetBinContent(bin), nprev=h->GetBinContent(bin-1);
    TString cutName(h->GetXaxis()->GetBinLabel(bin));
    cutName.ReplaceAll("#it{m}_{#gamma#gamma}","m_yy");
    if (bin==1||nprev==0||n==nprev)
      printf(format.Data(),cutName.Data(),n,-1e-10,n/ntot*100);
    else // if the cut does something, print more information
      printf(format.Data(),cutName.Data(),n,(n-nprev)/nprev*100,n/ntot*100);
  }

}
