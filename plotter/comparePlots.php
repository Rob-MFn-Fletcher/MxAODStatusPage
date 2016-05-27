<?php
  include('../html/vars.php');
  $compSample=$_GET["q"];  // q for "query" htag
  $currSample=$_GET["c"];  // c for "current" htag

  $command="source " . $base . "/plotter/comparePlots.sh ". $base . " ". $currSample . " " . $compSample . " 2>&1";

  $outpt=shell_exec($command);
  //echo $outpt;
 
  $getFilesCommand="for i in $(ls " . $base . "/tmp/". $currSample . "*" . $compSample . '* ); do basename $i; done;';
  //echo $getFilesCommand;
  $files=shell_exec($getFilesCommand);
  //echo $files;

  $filesArray=explode("\n", $files);
  for($i=0; $i<(count($filesArray) -1); $i++) {
    echo '<img src="' . $baseRel . '/tmp/' . $filesArray[$i] . '"' . '  style="width:696px;height:472px;">';
  }
 

?>
