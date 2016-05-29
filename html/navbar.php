<h1><img src="/atlas-hgamma/img/higgs.png" style="width:35px;height:35px;"> HGam MxAOD Status <img src="/atlas-hgamma/img/higgs.png" style="width:35px;height:35px;"> </h1>
<ul>
  <li><a class="active" href="/atlas-hgamma/mainPage.php?h=<?php
      include('vars.php');
      $dir = $base . "/variables/htags/";
      $page=shell_exec("ls $dir | grep -v pre | tail -n 1");
      echo $page;?>">Home
    </a></li>
  <li> 
<FORM NAME="nav"><DIV>
<SELECT NAME="SelectURL" onChange=
"document.location.href=
document.nav.SelectURL.options[document.nav.SelectURL.selectedIndex].value">
<OPTION VALUE=""
SELECTED>Select a different h-tag:
<?php
//include('vars.php');
$dir = $base . "/variables/htags/";
$html="";
foreach (scandir($dir,1) as $file) {
  if ('.' === $file) continue;
  if ('..' === $file) continue;
  $html=$html . '<OPTION VALUE="'. $baseRel ."/mainPage.php?h=". $file .'">' . $file;
}
echo $html;
?>

</SELECT><DIV>
</FORM> 
  </li>
</ul>
