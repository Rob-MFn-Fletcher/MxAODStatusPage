<!-- 
HGam Status Site
Author: Tony Thompson
i fucking hate html. PHP is neat tho

Redirects the home page to latest release (h012pre throws it off though)
-->

<?php
  include('html/vars.php');
  $dir = $base . "/variables/htags/";
  $page=shell_exec("ls $dir | grep -v pre | tail -n 1");
  $loc= 'Location: ' . $baseRel . '/mainPage.php?h=' . $page;
  header("$loc"); 
?>


