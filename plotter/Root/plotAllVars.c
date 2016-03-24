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

void plotAllVars(string oldDatasetName,int nOldFiles, string newDatasetName, int nNewFiles)
{
  // variables to plot are in defined in plotVars.h
  std::vector<string> variables(plotVars, plotVars + sizeof plotVars / sizeof plotVars[0]);

  TChain * oldFileChain=new TChain("CollectionTree");
  bool oldFileExists = true;
  
  if( nOldFiles == 0 )
  {
    oldFileExists=false;
  }
  else if( nOldFiles == 1 )
  {
    // if its only 1 file, then its not a folder
    oldFileChain->Add(oldDatasetName.c_str());
  }
  else // it's a folder! Negative numbers aren't actually possible, please don't put them in :P 
  {
    for(int i = 1; i <= nOldFiles;i++)
    {
      size_t found = oldDatasetName.find_last_of("/");
      string baseFileName=oldDatasetName.substr(found+1);
      size_t f = baseFileName.find(".root");
      string fileNum="";
      if(i < 10)         fileNum="00"+std::to_string(i);
      else if (i < 100)  fileNum="0"+std::to_string(i);
      else               fileNum=std::to_string(i);
      // MxAODs on EOS that are folders have .00x.root instead of .root at the end
      baseFileName.replace(f, baseFileName.length(), "."+fileNum+".root");
      string path=oldDatasetName+"/"+baseFileName;
      oldFileChain->Add(path.c_str());
    }
  }
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
   

    size_t found = newDatasetName.find_last_of("/");
    string baseFileName=newDatasetName.substr(found+1);
    TCanvas* c1 = new TCanvas;

    newFileChain->Draw(variables[i].c_str());
    TH1F *htemp = (TH1F*)gPad->GetPrimitive("htemp");
    //cout << htemp << endl;
    htemp->SetLineColor( kRed);
    float MeanVal=htemp->GetMean();
    float stdev  =htemp->GetStdDev();
    float xmin = MeanVal-2*stdev;
    if(xmin<-10000) // case for variables like Energy where there is no reason to have a negative xmin
    {
      xmin = 0;
    }
    float xmax = MeanVal+2*stdev;
    if(xmin==xmax)  // case for where there is no std dev for variables like m_ee in ggH125_small samples, so xmin==xmax and root gets confused
    {
      xmin = xmin - 1;
      xmax = xmax + 1;
    }

    TCanvas* c2 = new TCanvas;
    std::to_string(1);
    string lowCut=variables[i]+" > "+std::to_string(xmin);
    string highCut=variables[i]+" < "+std::to_string(xmax);
    string fullCut=lowCut+" && "+highCut;

    if(oldFileExists) // plot both if both exist
    {
      TBranch * varBranch = oldFileChain->GetBranch(variables[i].c_str());
      if(varBranch != 0)
      {
        //cout << "var exisits in h010! Plot Both on same plot" << endl;
        
        oldFileChain->Draw(variables[i].c_str(),fullCut.c_str());
        htemp = (TH1F*)gPad->GetPrimitive("htemp");
        int maxITER = 5;
        int iter=0;
        while( (htemp == 0 || htemp->Integral() < 5 ) && iter <= maxITER  )
        {
          fullCut = increaseCut(variables[i],MeanVal,stdev,xmin,xmax);
          oldFileChain->Draw(variables[i].c_str(),fullCut.c_str());
          htemp = (TH1F*)gPad->GetPrimitive("htemp");
          iter++;
          if(iter==maxITER) cout << "max iterations reached, might be no plot for " << variables[i] << endl;
        }
        htemp->SetLineColor( kRed);
        htemp->SetTitle(variables[i].c_str());
        c3 = new TCanvas;
        htemp->Draw();
        newFileChain->Draw(variables[i].c_str(),fullCut.c_str(),"same");
      }
      else
      {
        //cout << "var does not exist in h010! Plot only new" << endl;
        newFileChain->Draw(variables[i].c_str(),fullCut.c_str(),"");
      } 
    }
    else // only new file exists, plot that 
    {
      newFileChain->Draw(variables[i].c_str(),fullCut.c_str(),"");
    } 


    string plotName="samples/"+baseFileName+"/"+baseFileName+"_"+variables[i]+".png";
    c2->Print(plotName.c_str());
    delete c1; 
    delete c2; 
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
