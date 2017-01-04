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
      <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
      <script
          src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"
          integrity="sha256-VazP97ZCwtekAsvgPBSUwPFKdrwD3unUfSGVYrahUqU="
          crossorigin="anonymous"></script>
      <link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
      <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">

      <!-- Optional theme -->
      <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous">
      <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
      <link rel="stylesheet" href="../css/mystyle.css" />
      <script type="text/javascript">
        $(function() {
            $("#tabs").tabs();
        });
      </script>
  </head>
  <body bgcolor=white>
  <?php include_once('../html/navbar.php'); $currHtag=$_GET["h"]; ?>
  <h1>HGam MxAOD Sample Validation</h1>
    <p> Selected htag: <?php echo $currHtag;  ?> </p>
    <p> Note: In h014 there are two files that will not display the correct number of events. This is a known issue and is being worked on. The files are:</p>
        <p>mc15c.Sherpa_2DP20_myy_100_165_3jets.MxAODDetailed.p2666.h014.root/</p>
        <p>mc15c.Sherpa_2DP20_myy_165_200_3jets.MxAODDetailed.p2812.h014.root/</p>
<?php
  include("../html/vars.php");
?>

<div id="tabs">
    <ul>
        <li><a href="#data15-container">Data15</a></li>
        <li><a href="#data16-container">Data16</a></li>
        <li><a href="#mc-container">MC</a></li>
    </ul>
    <div id="data15-container">
        <h2>Data15</h2>
        <div id="data-table-container">
            <table class="table table-hover" id="data15-table" >
            </table>
        </div>
        <div class="col-sm-6 data-missing-samples">
            <div class="data-missing-samples-content">
            <h3> Missing Data Samples </h3>
            </div>
        </div>
        <div class="col-sm-6 data-missing-input">
            <div class="data-missing-input-content">
            <h3> Missing input</h3>
            </div>
        </div>
    </div>

    <div id="data16-container">
        <h2>Data16</h2>
        <div class="data-table-container">
            <table class="table table-hover data16-table" >
            </table>
        </div>
        <div class="col-sm-6 data-missing-samples">
            <div class="data-missing-samples-content">
            <h3> Missing data Samples </h3>
            </div>
        </div>
        <div class="col-sm-6 data-missing-input">
            <div class="data-missing-input-content">
            <h3> Missing input</h3>
            </div>
        </div>
    </div>

    <div id="mc-container">
        <h2>MC</h2>
        <div id="mc-table-container">
            <table class="table table-hover" id="mc-table" >
            </table>
        </div>
        <div id="mc-missing-samples" class="col-sm-6">
            <div id="mc-missing-samples-content">
            <h3> Missing MC Samples </h3>
            </div>
        </div>
        <div id="mc-missing-input" class="col-sm-6">
            <div id="mc-missing-input-content">
            <h3> Missing input</h3>
            </div>
        </div>
    </div>
</div>


<script type="text/javascript">var htag = "<?php echo $currHtag; ?>" ;</script>
<script type="text/javascript" src="NeventsCheck/fillTable.js"></script>


  </body>
</html>
