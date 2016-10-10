<html>
<html lang="en">
<head>
 <meta charset="utf-8" />
 <title><?php echo $currSample;  ?></title>
    <style>
    h1 {text-align:center;}
    p {text-align:center;}
    </style>
    <link rel="stylesheet" href="../css/mystyle.css" />
</head>

<?php
include('../html/vars.php');
$currSample=$_GET["s"];
$currHtag=$_GET["h"];
?>

<script>
function showCutflow(str) {
  if (str.length==0) {
    document.getElementById("cutflowform").innerHTML="";
    document.getElementById("cutflowform").style.border="0px";
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
      document.getElementById("cutflowform").innerHTML=xmlhttp.responseText;
      //document.getElementById("livesearch").style.border="1px solid #A5ACB2";
    }
  }
  xmlhttp.open("GET","../AllCutflows/compareCutflows.php?q="+str+"&c="+"<?php echo $currSample;  ?>",true);
  xmlhttp.send();
}
function showPlots(str) {
  if (str.length==0) {
    document.getElementById("htagform").innerHTML="";
    document.getElementById("htagform").style.border="0px";
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
      document.getElementById("htagform").innerHTML=xmlhttp.responseText;
      //document.getElementById("livesearch").style.border="1px solid #A5ACB2";
    }
  }
  xmlhttp.open("GET","../plotter/comparePlots.php?q="+str+"&c="+"<?php echo $currSample;  ?>",true);
  xmlhttp.send();
}
function showVarDiff(str) {
  if (str.length==0) {
    document.getElementById("variablesform").innerHTML="";
    document.getElementById("variablesform").style.border="0px";
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
      document.getElementById("variablesform").innerHTML=xmlhttp.responseText;
      //document.getElementById("livesearch").style.border="1px solid #A5ACB2";
    }
  }
  xmlhttp.open("GET","../variables/getVarDiffs.php?q="+str+"&c="+"<?php echo $currSample;  ?>",true);
  xmlhttp.send();
}
</script>
<body bgcolor=white> 
<?php include_once('../html/navbar.php'); ?> 
<h1><?php echo $currSample;  ?></h1>
<p>Location: <?php
  $command="grep " . $currSample . " ". $base ."/samplePage/htags/" . $currHtag . "/fileLocs.txt | awk '{print $2}'";
  $EOS_LOC=shell_exec($command);
  echo $EOS_LOC; ?>
</p>
<table class="center">
<tr>
Compare Cutflow To ...
<select name="cutflowList" onChange="showCutflow(this.value);">
  <option value="">Select sample...</option>
  <?php
    $command="source " . $base . "/plotter/getSamples.sh " . $base  . " ". $currSample;
    $files=shell_exec($command);
    $filesArray=explode("\n", $files);
    $html="";
    for($i=0; $i<(count($filesArray) -1); $i++) {
      $html=$html . "<option value=\"". $filesArray[$i] . "\">" . $filesArray[$i] . "</option>";
    }
    echo $html;
  ?>
</select>
<h2>Cutflow</h2>
<td><p><?php echo $currHtag;  ?></p></td>
</tr>
<tr>
<td><object width="484" height="300" type="text/plain" data="../AllCutflows/cutflows/<?php echo $currHtag;  ?>/<?php echo $currSample;  ?>.txt" border="0"></object></td>
</tr>
</table>
<p><div id="cutflowform"></div></p>

Compare Variables To (wait a few seconds)...
<select name="formVar" onChange="showVarDiff(this.value);">
  <option value="">Select sample...</option>
  <?php
    $command="source " . $base . "/variables/getSamples.sh " . $base  . " " . $currSample;
    $files=shell_exec($command);
    $filesArray=explode("\n", $files);
    $html="";
    for($i=0; $i<(count($filesArray) -1); $i++) {
      $html=$html . "<option value=\"". $filesArray[$i] . "\">" . $filesArray[$i] . "</option>";
    }
    echo $html;
  ?>
</select>
<h2>Variables</h2>
<p><div id="variablesform"></div></p>
<p><object width="1000" height="300" type="text/plain" data="../variables/htags/<?php echo $currHtag;  ?>/<?php echo $currSample;  ?>_vars.txt" border="0"></object></p>



Compare Variable Distributions To (wait a few seconds)...
<select name="formVarPlots" onChange="showPlots(this.value);">
  <option value="">Select sample...</option>
  <?php
    $command="source " . $base . "/plotter/getSamples.sh " . $base  . " " . $currSample;
    $files=shell_exec($command);
    $filesArray=explode("\n", $files);
    $html="";
    for($i=0; $i<(count($filesArray) -1); $i++) {
      $html=$html . "<option value=\"". $filesArray[$i] . "\">" . $filesArray[$i] . "</option>";
    }
    echo $html;
  ?>
</select>
<h2>Comparison Plots</h2> 
<p><div id="htagform"></div></p>
</body>
</html>
