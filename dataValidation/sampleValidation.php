<!--
HGam Status Site
Author: Rob Fletcher
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
      <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
      <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
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
<?php
  include("../html/vars.php");
?>
<div id="data-container">
    <h2>Data</h2>

</div>
<div id="mc-container">
    <h2>MC</h2>
    <div id="mc">
        <table class="table table-hover" id="mc-table">
        </table>
    </div>
</div>


<script type="text/javascript" src="fillTable.js"></script>


  </body>
</html>
