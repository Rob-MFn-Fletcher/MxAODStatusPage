<html>
  <html lang="en">
  <head>
<script>
<?php
  include("../html/vars.php");
  $currHtag=$_GET["h"];
?>
function showResult(str) {
  if (str.length==0) {
    document.getElementById("livesearch").innerHTML="";
    document.getElementById("livesearch").style.border="0px";
    return;
  }
  if (window.XMLHttpRequest) {
    // code for IE7+, Firefox, Chrome, Opera, Safari
    xmlhttp=new XMLHttpRequest();
  } else {  // code for IE6, IE5
    xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
  }
  xmlhttp.onreadystatechange=function() {
    if (xmlhttp.readyState==4 && xmlhttp.status==200) {
      document.getElementById("livesearch").innerHTML=xmlhttp.responseText;
      document.getElementById("livesearch").style.border="1px solid #A5ACB2";
    }
  }
  xmlhttp.open("GET","liveSearch/livesearch.php?q="+str+"&h="+"<?php echo "$currHtag";  ?>",true);
  xmlhttp.send();
}
</script>
  <meta charset="utf-8" />
    <title>HGam MxAOD Status</title>
      <style>
      h1 {text-align:center;}
      p {text-align:center;}
      </style>
      <link rel="stylesheet" href="mystyle.css" />
  </head>
  <body bgcolor=white>
  <?php include_once('html/navbar.php'); ?>


  <p> Selected htag: <?php echo $currHtag;  ?> </p>

  <p><a href="dataValidation/sampleValidation.php?&h=<?php echo $currHtag;  ?>">Data Validation</a><p>

<form>Search for your sample (click sample for specific sample page):
<input type="text" size="30" onkeyup="showResult(this.value)">
<div id="livesearch"></div>
</form>

  </body>
</html>


