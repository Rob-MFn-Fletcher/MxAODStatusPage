<!-- 
HGam Status Site
Author: Tony Thompson
i fucking hate html
-->
<html>
  <html lang="en">
  <head>
 <script>
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
  xmlhttp.open("GET","liveSearch/livesearch.php?q="+str,true);
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

    <h1>HGam MxAOD Status Page</h1>

    <p> Last updated for htag: : <?php $line = fgets(fopen('CurrentHtag.txt', 'r')); echo $line ?> </p>

<p><a href="dataValidation/dataValidation.php">Data Validation</a><p>
<p><a href="#Variables">Variables</a> </p>
<p><a href="#FileSize">File Size Stats</a> </p>
<p><a href="#Cutflows">Cutflows</a> </p>

<form>Search for your sample (click sample for specific sample page):
<input type="text" size="30" onkeyup="showResult(this.value)">
<div id="livesearch"></div>
</form>



<a name="Variables"></a><h1>Variables</h1>
<!-- Ugly but it works...  -->
<p>The following variables were added in the latest htag &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; The following variables were removed from the previous htag</p>
<p>
<object width="470" height="300" type="text/plain" data="variables/addedVars.txt" border="0"></object>
<object width="470" height="300" type="text/plain" data="variables/removedVars.txt" border="0"></object>
</p>
<p>Full Variable List</p>
<p><object width="870" height="300" type="text/plain" data="variables/allVars.txt" border="0"></object></p>
<a name="FileSize"></a><h1>File Size Stats</h1>
<p>
<object width="670" height="300" type="text/plain" data="fileSize/fileSize.txt" border="0"></object>
</p>

<a name="Cutflows"><h1>Cutflows</h1>
<p><object width="500" height="300" type="text/plain" data="cutflows/data15_13TeV.periodAll25ns.physics_Main.txt" border="0"></object>
<object width="484" height="300" type="text/plain" data="cutflows/PowhegPy8_ggH125_small.txt" border="0"></object>
<object width="484" height="300" type="text/plain" data="cutflows/PowhegPy8_VBF125_small.txt" border="0"></object>
<object width="484" height="300" type="text/plain" data="cutflows/Pythia8_WH125.txt" border="0"></object>
<object width="484" height="300" type="text/plain" data="cutflows/Pythia8_ZH125.txt" border="0"></object>
<object width="484" height="300" type="text/plain" data="cutflows/Pythia8_ttH125.txt" border="0"></object></p>
  </body>
</html>
