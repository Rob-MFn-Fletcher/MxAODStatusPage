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
      <script src="https://cdnjs.cloudflare.com/ajax/libs/floatthead/1.4.5/jquery.floatThead.min.js"></script>
      <link rel="stylesheet" href="../css/mystyle.css" />
  </head>
  <body bgcolor=white>
  <?php include_once('../html/navbar.php'); $currHtag=$_GET["h"]; ?>
  <h1>HGam MxAOD Sample Validation</h1>
    <p> Selected htag: <?php echo $currHtag;  ?> </p>
<?php
  include("../html/vars.php");
?>

<div id="tabs">
</div>

<script type="text/javascript">
     var htag = "<?php echo $currHtag; ?>"
    //<?php
        //$paths = glob("./data/"+$currHtag+"/Validation_*.json");
    //    $paths[] = glob("./data/".$currHtag."/Validation*");
    //    foreach($paths as $paths){
    //      $paths = str_replace("ValidationTable_","",basename($paths, '.json'));
    //    }
    //    echo "var samples = " . json_encode($samples) . ";";
    //    echo "var paths = ".json_encode($paths).";";
    // ?>
     //console.log("paths are: "+ paths);
     //console.log(samples);
</script>

<script type="text/javascript" src="NeventsCheck/fillTable.js"></script>

<!--
<script type="text/javascript">
$(function() {
    $("#tabs").tabs();
});
</script>
-->
  </body>
</html>
