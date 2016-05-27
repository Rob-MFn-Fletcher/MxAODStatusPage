<!-- 
HGam Status Site
Author: Tony Thompson
i fucking hate html. PHP is neat tho

Redirects the home page to latest release (h012pre throws it off though)
-->

<?php
  include('html/vars.php');
  $dir = $base . "/variables/htags/";
  $pages = scandir($dir,1);
  $loc= 'Location: ' . $baseRel . '/mainPage.php?h=' . $pages[0];
  header("$loc"); 
?>


