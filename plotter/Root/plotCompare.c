#include <string>
#include <cmath>
#include <vector>
#include <iostream>
#include <fstream>
#include "plotVars.h"

string increaseCut(string variableName,float MeanVal, float stdev,float &xmin, float &xmax){

  xmin -= 2*stdev;
  if(xmin<-10000) // case for variables like Energy where there is no reason to have a negative xmin
  {
    xmin = 0;
  }
  xmax +=2*stdev;
  if(xmin==xmax)  // case for where there is no std dev for variables like m_ee in ggH125_small samples, so xmin==xmax and root gets confused
  {
    xmin = xmin - 1;
    xmax = xmax + 1;
  }

  string lowCut =variableName+" > "+std::to_string(xmin);
  string highCut=variableName+" < "+std::to_string(xmax);
  string fullCut=lowCut+" && "+highCut;
  return fullCut;
}

void plotCompare(string currDatasetName,string currHtag, string compDatasetName, string compHtag)
{
  
  //cout << "WOOOOOOOOO" << endl;
  //return;
  if (currDatasetName=="")
  {
    cerr << "no new dataset name? what the hell do you want me to do? Returning..." << endl;
    return;
  }
  
  std::vector<string> variables(plotVars, plotVars + sizeof plotVars / sizeof plotVars[0]);

  TFile* currDataSet = TFile::Open(currDatasetName.c_str());
  TFile* compDataSet = TFile::Open(compDatasetName.c_str());
  gStyle->SetOptStat(0);

  float progress=0.0;
  size_t currfound = currDatasetName.find_last_of("/");
  string currBaseFileName=currDatasetName.substr(currfound+1); 
  
  size_t compfound = compDatasetName.find_last_of("/");
  string compBaseFileName=compDatasetName.substr(compfound+1); 
  for(unsigned int i =0; i< variables.size();i++)
  {
    //cout << variables[i] << endl;
    //if (variables[i] != "HGamEventInfoAuxDyn.m_yy_truthVertex" ) continue;
    int barWidth = 70;
    std::cout << "[";
    int pos = barWidth * progress;
    for (int i = 0; i < barWidth; ++i) {
        if (i < pos) std::cout << "=";
        else if (i == pos) std::cout << ">";
        else std::cout << " ";
    }
    std::cout << "] " << int(progress * 100.0) << " %\r";
    std::cout.flush(); 
   

    TCanvas* c1 = new TCanvas;

    TH1F * currHist = (TH1F *) currDataSet->Get(variables[i].c_str());
    if(currHist == 0)
    {
      cout << "curr hist is null for var " << variables[i] << endl;
      continue;
    }
    int NbinsCurr=currHist->GetNbinsX();

    TH1F * compHist = (TH1F *) compDataSet->Get(variables[i].c_str());
    if(compHist == 0)
    {
      cout << "comp hist is null for var " << variables[i] << endl;
      continue;
    }
    int NbinsComp=compHist->GetNbinsX();
    

    compHist->SetLineColor( kRed);

    TLegend* leg = new TLegend(0.8, 0.8, .9, .9);
    leg->AddEntry(currHist, currHtag.c_str(), "l");
    leg->AddEntry(compHist, compHtag.c_str(), "l");

    compHist->Draw("");
    currHist->Draw("same");
    leg->Draw("same");
   
    string filename="/afs/cern.ch/user/a/athompso/www/tmp/"+currBaseFileName+"_"+variables[i]+"_"+compBaseFileName+".png";
    c1->Print(filename.c_str());
    //cout << htemp << endl;
    progress += 1.0/variables.size();

  }
  int barWidth=70;
  std::cout << "[";
  int pos = barWidth * 1;
  for (int i = 0; i < barWidth; ++i) {
      if (i < pos) std::cout << "=";
      else if (i == pos) std::cout << ">";
      else std::cout << " ";
  }
  std::cout << "] " << int(1 * 100.0) << " %\r";
  std::cout.flush(); 
  cout << endl;

}
