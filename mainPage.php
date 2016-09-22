<html>
    <html lang="en">
    <head>
        <?php
            include("../html/vars.php");
            $currHtag=$_GET["h"];
        ?>
        <script type="text/javascript" src="js/livesearch.js"></script>
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
