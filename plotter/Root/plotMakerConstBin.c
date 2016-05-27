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
  string fullCut=lowCut+" && "+highCut+" && HGamEventInfoAuxDyn.isPassedPreselection";
  return fullCut;
}

void plotMakerConstBin(string htag,string newDatasetName, unsigned int nNewFiles)
{
  if (newDatasetName=="")
  {
    cerr << "no new dataset name? what the hell do you want me to do? Returning..." << endl;
    return;
  }
  // variables to plot are in defined in plotVars.h
  std::vector<string> variables(plotVars, plotVars + sizeof plotVars / sizeof plotVars[0]);

  
  TChain * newFileChain=new TChain("CollectionTree");
  if(nNewFiles == 0)
  {
    cerr << "No files in new dataset? This shouldn't happen.  Something has gone wrong. Check inputs" << endl;
    return;
  }
  else if(nNewFiles == 1)
  {
    // if its only 1 file, then its not a folder
    newFileChain->Add(newDatasetName.c_str());
  }
  else // it's folder!
  {
    for(int i = 1; i <= nNewFiles;i++)
    {
      size_t found = newDatasetName.find_last_of("/");
      string baseFileName=newDatasetName.substr(found+1);
      size_t f = baseFileName.find(".root");
      string fileNum="";
      if(i < 10)         fileNum="00"+std::to_string(i);
      else if (i < 100)  fileNum="0"+std::to_string(i);
      else               fileNum=std::to_string(i);

      baseFileName.replace(f, baseFileName.length(), "."+fileNum+".root");
      string path=newDatasetName+"/"+baseFileName;
      newFileChain->Add(path.c_str());
    }
  }

  float progress=0.0;
    size_t found = newDatasetName.find_last_of("/");
    string baseFileName=newDatasetName.substr(found+1);
  string outfilename="samples/"+htag+"/"+baseFileName;
  TFile f(outfilename.c_str(),"recreate"); 
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
   

    //size_t found = newDatasetName.find_last_of("/");
    //string baseFileName=newDatasetName.substr(found+1);
    
    //cout << "1" << endl;
    if(newFileChain->Draw(variables[i].c_str(),"") == -1)
    {
      cout << "Draw command failed!" << endl;
      progress += 1.0/variables.size();
      continue;
    }
    //cout << "2" << endl;
    TH1F *htemp = (TH1F*)gPad->GetPrimitive("htemp");
    if (htemp==0)
    {
      cout << "histo is empty for var " << variables[i] << ", must have no entries" << endl;
      continue;
    }
    //cout << "2" << endl;
    
    //cout << htemp << endl;
    htemp->SetLineColor( kRed);
    float MeanVal=htemp->GetMean();
    float stdev  =htemp->GetStdDev();
    float xmin = MeanVal-2*stdev;
    long xminRound=floor(xmin/1000)*1000;
    if(xmin<-10000) // case for variables like Energy where there is no reason to have a negative xmin
    {
      xminRound = 0;
    }
    float xmax = MeanVal+2*stdev;
    long xmaxRound=floor(xmax/1000)*1000;
    if(xmin==xmax)  // case for where there is no std dev for variables like m_ee in ggH125_small samples, so xmin==xmax and root gets confused
    {
      xmin = xmin - 1000;
      xmax = xmax + 1000;
    }

    string lowCut=variables[i]+" > "+std::to_string(xmin);
    string highCut=variables[i]+" < "+std::to_string(xmax);
    string fullCut=lowCut+" && "+highCut+" && HGamEventInfoAuxDyn.isPassedPreselection";


    long nBins=(xmaxRound-xminRound)/1000;
    TH1F * hist = new TH1F("hist",variables[i].c_str(),nBins,xminRound,xmaxRound);  

    string plotVar=variables[i]+">>htemp("+to_string(nBins)+","+to_string(xminRound)+","+to_string(xmaxRound)+")";
    newFileChain->Draw(plotVar.c_str(),fullCut.c_str(),"");
    htemp = (TH1F*)gPad->GetPrimitive("htemp");
    //cout << "3" << endl;
    int maxITER = 5;
    int iter=0;
    //while( (htemp == 0 || htemp->Integral() < 5 ) && iter <= maxITER  )
    //{
    //  fullCut = increaseCut(variables[i],MeanVal,stdev,xmin,xmax);
    //  newFileChain->Draw(variables[i].c_str(),fullCut.c_str());
    //  htemp = (TH1F*)gPad->GetPrimitive("htemp");
    //  iter++;
    // 
    //  if(iter==maxITER) cout << "max iterations reached, might be no plot for " << variables[i] << endl;
    //}
    htemp->SetNameTitle(variables[i].c_str(),variables[i].c_str());
    htemp->Write();

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
  f.Close();
}
