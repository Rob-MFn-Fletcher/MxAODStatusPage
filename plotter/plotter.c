#include <string>
#include <cmath>
#include <vector>
#include <iostream>
#include <fstream>
void plotter(string oldFileName, string newFileName)
//void plotter()
{
  string vars[36]={"HGamEventInfoAuxDyn.cosTS_yy","HGamEventInfoAuxDyn.Dphi_yy_jj","HGamEventInfoAuxDyn.DRmin_y_j","HGamEventInfoAuxDyn.DR_y_y","HGamEventInfoAuxDyn.Dy_j_j","HGamEventInfoAuxDyn.Dy_y_y","HGamEventInfoAuxDyn.Dy_yy_jj","HGamEventInfoAuxDyn.E_y1","HGamEventInfoAuxDyn.E_y2","HGamEventInfoAuxDyn.m_ee","HGamEventInfoAuxDyn.met_TST","HGamEventInfoAuxDyn.m_jj","HGamEventInfoAuxDyn.m_mumu","HGamEventInfoAuxDyn.mu","HGamEventInfoAuxDyn.m_yy_hardestVertex","HGamEventInfoAuxDyn.m_yy","HGamEventInfoAuxDyn.m_yy_resolution","HGamEventInfoAuxDyn.m_yy_truthVertex","HGamEventInfoAuxDyn.m_yy_zCommon","HGamEventInfoAuxDyn.N_e","HGamEventInfoAuxDyn.N_j","HGamEventInfoAuxDyn.NLoosePhotons","HGamEventInfoAuxDyn.N_mu","HGamEventInfoAuxDyn.numberOfPrimaryVertices","HGamEventInfoAuxDyn.phi_TST","HGamEventInfoAuxDyn.pT_hard","HGamEventInfoAuxDyn.pT_j1","HGamEventInfoAuxDyn.pT_j2","HGamEventInfoAuxDyn.pT_jj","HGamEventInfoAuxDyn.pTt_yy","HGamEventInfoAuxDyn.pT_y1","HGamEventInfoAuxDyn.pT_y2","HGamEventInfoAuxDyn.pT_yy","HGamEventInfoAuxDyn.sumet_TST","HGamEventInfoAuxDyn.yAbs_yy","HGamEventInfoAuxDyn.Zepp"};
  std::vector<string> variables(vars, vars + sizeof vars / sizeof vars[0]);

  //TFile * oldFile = TFile::Open("root://eosatlas.cern.ch//eos/atlas/atlascerngroupdisk/phys-higgs/HSG1/MxAOD/h010/mc_25ns/PowhegPy8_ggH125_small.MxAOD.p2421.h010.root");
  //TFile * newFile = TFile::Open("root://eosatlas.cern.ch//eos/atlas/atlascerngroupdisk/phys-higgs/HSG1/MxAOD/h011/mc_25ns/PowhegPy8_ggH125_small.MxAOD.p2421.h011.root");
  TFile * oldFile = TFile::Open(oldFileName.c_str());
  TFile * newFile = TFile::Open(newFileName.c_str());
  TTree* oldCollecTree =(TTree*)oldFile->Get("CollectionTree"); 
  TTree* newCollecTree =(TTree*)newFile->Get("CollectionTree"); 
  float progress=0.0;
   
  for(unsigned int i =0; i< variables.size();i++)
  {
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
    //cout << "variable: " << variables[i] << endl; 
    
    string fileName=newFile->GetName();
    size_t found = fileName.find_last_of("/");
    string baseFileName=fileName.substr(found+1);
    TCanvas* c1 = new TCanvas;


    //oldCollecTree->Draw("HGamEventInfoAuxDyn.m_yy","HGamEventInfoAuxDyn.m_yy<160000&&HGamEventInfoAuxDyn.m_yy>80000");
    //oldCollecTree->Draw("HGamEventInfoAuxDyn.m_yy","HGamEventInfoAuxDyn.m_yy<800000&&HGamEventInfoAuxDyn.m_yy>600000");
    //cout << "1" << endl;
    newCollecTree->Draw(variables[i].c_str());
    TH1F *htemp = (TH1F*)gPad->GetPrimitive("htemp");
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
    //cout << "2" << endl;
    TBranch * varBranch = oldCollecTree->GetBranch(variables[i].c_str());
    if(varBranch != 0)
    {
      //cout << "var exisits in h010! Plot Both" << endl;
      oldCollecTree->Draw(variables[i].c_str(),fullCut.c_str());
      htemp = (TH1F*)gPad->GetPrimitive("htemp");
      //cout << htemp << endl;
      htemp->SetLineColor( kRed);
      htemp->SetTitle(variables[i].c_str());
      newCollecTree->Draw(variables[i].c_str(),fullCut.c_str(),"same");
    }
    else
    {
      //cout << "var does not exist in h010! Plot only new" << endl;
      newCollecTree->Draw(variables[i].c_str(),fullCut.c_str(),"");
    } 
    
    string plotName="samples/"+baseFileName+"/"+baseFileName+"_"+variables[i]+".png";
    c2->Print(plotName.c_str());
    delete c1; 
    delete c2; 
    progress += 1.0/variables.size();
    // cout << oldCollecTree->Draw("HGamEventInfoAuxDyn.m_yy") << endl;;

  }
  int barWidth=70;
  std::cout << "[";
  int pos = barWidth * progress;
  for (int i = 0; i < barWidth; ++i) {
      if (i < pos) std::cout << "=";
      else if (i == pos) std::cout << ">";
      else std::cout << " ";
  }
  std::cout << "] " << int(progress * 100.0) << " %\r";
  std::cout.flush(); 
  cout << endl;

}




