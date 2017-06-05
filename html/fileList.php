<?php
$currHtag=$_GET["h"];
echo json_encode(glob("../dataValidation/data/".$currHtag."/ValidationTable*"));
?>
