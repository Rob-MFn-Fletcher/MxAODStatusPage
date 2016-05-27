<?php
  // php script to call a bash script that compares two cutflows and outputs the information 
  include('../html/vars.php');
  $compSample=$_GET["q"];  // q for "query" htag
  $currSample=$_GET["c"];  // c for "current" htag

  $command="source " . $base . "/AllCutflows/compareCutflows.sh " . $currSample . " " . $compSample . " " . $base ." 2>&1";

  $outpt=shell_exec($command);
  echo $outpt;
 
?>
