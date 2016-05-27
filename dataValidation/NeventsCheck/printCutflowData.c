#include <string>
#include <cmath>
#include <vector>
#include <iostream>
#include <fstream>

void printCutflowData(string s) {
  TFile* f = TFile::Open(s.c_str());


  TList * AllKeys=f->GetListOfKeys();
  int NKeys = AllKeys->GetEntries();
  //cout << NKeys << endl;
  TIter next(AllKeys);
  TKey *key;
  vector<TKey* > cutflowKeys;
  for(int i =0 ; i < NKeys ; i++)
  {
    key=(TKey*)next();
    string name = key->GetTitle();
    if(name.find("CutFlow") != std::string::npos)
    {
      cutflowKeys.push_back(key);
      //cout << name << endl;
      
    }
  }
  TCanvas * c1 = new TCanvas;
  TH1F *h = (TH1F*)cutflowKeys[0]->ReadObj();
  for(int i=1; i<cutflowKeys.size();i++)
  {
    TH1F *temp = (TH1F*)cutflowKeys[i]->ReadObj();
    h->Add(temp);
  } 
  
  int Ndecimals = 2;
    enum CutEnum {
    NxAOD=0, NDxAOD=1, ALLEVTS=2, DUPLICATE=3, TRIGGER=4, GRL=5, DQ=6, VERTEX=7, TWO_LOOSE_GAM=8, AMBIGUITY=9,
    TRIG_MATCH=10, GAM_TIGHTID=11, GAM_ISOLATION=12, RELPTCUTS=13, MASSCUT=14, PASSALL=15 };

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
