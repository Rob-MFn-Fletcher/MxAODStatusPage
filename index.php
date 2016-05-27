<!-- 
HGam Status Site
Author: Tony Thompson
i fucking hate html

-->

<?php
  include('html/vars.php');
  $dir = $base . "/variables/htags/";
  $pages = scandir($dir,1);
  $loc= 'Location: ' . $baseRel . '/mainPage.php?h=' . $pages[0];
  header("$loc"); 
?>


