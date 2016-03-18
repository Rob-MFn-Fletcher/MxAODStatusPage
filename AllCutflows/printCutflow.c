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

void printCutflow(string s) {
  //TFile* f = new TFile(s.c_str());
  TFile* f = TFile::Open(s.c_str());
  
  int Ndecimals = 2;
  TIter next(gDirectory->GetListOfKeys());
  TKey *key;
    enum CutEnum {
    NxAOD=0, NDxAOD=1, ALLEVTS=2, DUPLICATE=3, TRIGGER=4, GRL=5, DQ=6, VERTEX=7, TWO_LOOSE_GAM=8, AMBIGUITY=9,
    TRIG_MATCH=10, GAM_TIGHTID=11, GAM_ISOLATION=12, RELPTCUTS=13, MASSCUT=14, PASSALL=15 };
  key = (TKey*)next();
  TCanvas * c1 = new TCanvas;
  string name = key->GetTitle();
  while (name.find("CutFlow") == std::string::npos)
  {
      key = (TKey*)next();
      name = key->GetTitle();
  }
  TH1F *h = (TH1F*)key->ReadObj();

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
