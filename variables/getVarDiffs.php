<?php
  include('../html/vars.php');
  $q=$_GET["q"];  // q for "query" sample
  $c=$_GET["c"];  // c for "current" sample
  $commandRem= 'source ' . $base .'/variables/getVarsRemoved.sh ' . $c . ' ' . $q . ' ' . $base.' 2>&1';
  $commandAdd= 'source ' . $base .'/variables/getVarsAdded.sh ' . $c . ' ' . $q . ' '. $base.' 2>&1';

  //$outpt=shell_exec('source /afs/cern.ch/user/a/athompso/www/variables/test.sh 2>&1'); 
  //shell_exec('source /afs/cern.ch/user/a/athompso/www/variables/test.sh 2>&1');
  //$outpt=shell_exec('ls /tmp/'); 
  //echo $outpt;
  //echo '<img src="/atlas-project-HGamMxAODStatus/tmp/Pythia8_WH80.MxAOD.p2421.h011.root_HGamEventInfoAuxDyn.m_yy_hardestVertex_h010.png"  style="width:696px;height:472px;">';
  //echo '<img src="/atlas-project-HGamMxAODStatus/tmp/Pythia8_WH80.MxAOD.p2421.h011.rootHGamEventInfoAuxDyn.m_yy.png"  style="width:696px;height:472px;">';
  $outputRem = shell_exec($commandRem);
  $outputAdd = shell_exec($commandAdd);
  
  $removedVars = explode("\n", $outputRem);
  $addedVars = explode("\n", $outputAdd);
  echo 'The following variables from ' . $q . ' are not in ' .$c;
  echo '<pre>';
  if(count($removedVars) == 1){
    echo 'None';
  }
  for($i=0; $i<(count($removedVars)); $i++) {
  echo $removedVars[$i] . '<br />';
  }
  echo '</pre>';
  echo 'The following variables from ' . $c . ' are not in ' . $q;
  echo '<pre>';
  if(count($addedVars) == 1){
    echo 'None';
  }
  for($i=0; $i<(count($addedVars)); $i++) {
  echo $addedVars[$i] . '<br />';
  }
  echo '</pre>';
?>
