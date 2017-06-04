<?php
$currHtag=$_GET["h"];
$jsonFiles[] = array();
foreach(glob("../dataValidation/data/".$currHtag."/ValidationTable_*" as $file)){
  array_push($jsonFiles, $file);
}

echo json_encode($jsonFiles);
?>
