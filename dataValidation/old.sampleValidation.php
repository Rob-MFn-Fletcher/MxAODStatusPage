<!--
HGam Status Site
Author: Tony Thompson
i fucking hate html
-->
<html>
  <html lang="en">
  <head>

  <meta charset="utf-8" />
    <title>HGam MxAOD Data Validation</title>
      <style>
      h1 {text-align:center;}
      p {text-align:center;}
      </style>
      <link rel="stylesheet" href="../mystyle.css" />
  </head>
  <body bgcolor=white>
  <?php include_once('../html/navbar.php'); $currHtag=$_GET["h"]; ?>
  <h1>HGam MxAOD Sample Validation</h1>
    <p> Selected htag: <?php echo $currHtag;  ?> </p>
    <p> Note: In h014 there are two files that will not display the correct number of events. This is a known issue and is being worked on. The files are:</p>
    <ul>
        <li>mc15c.Sherpa_2DP20_myy_100_165_3jets.MxAODDetailed.p2666.h014.root/</li>
        <li>mc15c.Sherpa_2DP20_myy_165_200_3jets.MxAODDetailed.p2812.h014.root/</li>
    </ul>
<h2>Data</h2>
<?php
  include("../html/vars.php");
  $getTableFiles="for i in  $( ls " . $base . "/dataValidation/data/". $currHtag ."/Vali*data* ); do basename ".'$i'."; done;";
  $getMissingEventsFiles="for i in  $( ls " . $base . "/dataValidation/data/". $currHtag ."/samplesMissingEvents*data* ); do basename ".'$i'."; done;";
  $getMissingParentFiles="for i in  $( ls " . $base . "/dataValidation/data/". $currHtag ."/samplesMissingParents*data* ); do basename ".'$i'."; done;";

  $tableFiles=shell_exec($getTableFiles);
  $tablesArray=explode("\n", $tableFiles);

  $missingEventsFiles=shell_exec($getMissingEventsFiles);
  $missingEventsArray=explode("\n",$missingEventsFiles);

  $missingParentsFiles=shell_exec($getMissingParentFiles);
  $missingParentsArray=explode("\n",$missingParentsFiles);
  if (count($tablesArray) -1 == 0) {
    echo "<p1>no data for this release</p1>";
  }
  else {
    for($i=0; $i<(count($tablesArray) -1); $i++) {
      echo "<object width=\"1320\" height=\"500\" type=\"text/plain\" data=\"" . $baseRel . "/dataValidation/data/". $currHtag ."/" . $tablesArray[$i] . "\"  border=\"0\"></object>";
      echo '<object width="484" height="300" type="text/plain" data="data/'. $currHtag .'/'. $missingEventsArray[$i]  .'" border="0"></object>';
      echo '<object width="484" height="300" type="text/plain" data="data/'. $currHtag .'/'. $missingParentsArray[$i]  .'" border="0"></object>';
    }
    echo '<object width="484" height="300" type="text/plain" data="data/'. $currHtag .'/MissingSamples_data.txt" border="0"></object>';
  }
  echo '<h2>MC</h2>';
  $getFilesCommand="basename $(ls " . $base . "/dataValidation/data/". $currHtag ."/Vali*MC* )";
  $file=shell_exec($getFilesCommand);

  if ($file == ""){
    echo "<p1>no data for this release</p2>";
  }
  else {
    echo "<object width=\"1320\" height=\"600\" type=\"text/plain\" data=\"" . $baseRel . "/dataValidation/data/". $currHtag."/" . $file . "\"  border=\"0\"></object>";
    echo '<object width="484" height="300" type="text/plain" data="data/'. $currHtag .'/MissingSamples_MC.txt" border="0"></object>';
    echo '<object width="484" height="300" type="text/plain" data="data/'. $currHtag .'/samplesMissingEvents_MC.txt" border="0"></object>';
    echo '<object width="484" height="300" type="text/plain" data="data/'. $currHtag .'/samplesMissingParents_MC.txt" border="0"></object>';
  }

?>



  </body>
</html>
