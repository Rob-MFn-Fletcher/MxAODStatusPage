<html>
    <html lang="en">
    <head>
        <?php
            include("../html/vars.php");
            $currHtag=$_GET["h"];
        ?>
        <script type="text/javascript" src="js/livesearch.js"></script>
        <script type="text/javascript" src="js/navbar.js"></script>
        <meta charset="utf-8" />
        <title>HGam MxAOD Status</title>
        <style>
        h1 {text-align:center;}
        p {text-align:center;}
        </style>
        <link rel="stylesheet" href="css/mystyle.css" />
    </head>
    <body bgcolor=white>
        <div id="jumbotron">
            <ul>
                <li><img class="higgs" src="/atlas-hgamma/img/higgs.png"></li>
                <li><p> HGam MxAOD Status </p></li>
                <li><img class="higgs" src="/atlas-hgamma/img/higgs.png"></li>
            </ul>
        </div>
        <!--
        <?php include_once('html/navbar.php'); ?>
        -->
        <nav>
          <ul>
            <li><a href="#">Home</a></li>
            <li>
              <a href="#">Link 2</a>
              <ul class="fallback">
                <li><a href="#">Sub-Link 1</a></li>
                <li><a href="#">Sub-Link 2</a></li>
                <li><a href="#">Sub-Link 3</a></li>
              </ul>
            </li>
            <li>
              <a href="dataValidation/sampleValidation.php?&h=<?php echo $currHtag;  ?>">Data Validation</a>
              <ul class="fallback">
                <li><a href="#">Sub-Link 1</a></li>
                <li><a href="#">Sub-Link 2</a></li>
                <li><a href="#">Sub-Link 3</a></li>
                <li><a href="#">Sub-Link 4</a></li>
              </ul>
            </li>
            <li><a href="#">Selected htag: <?php echo $currHtag;  ?></a></li>
          </ul>
        </nav>

        <p> Selected htag: <?php echo $currHtag;  ?> </p>


        <form>Search for your sample (click sample for specific sample page):
        <input type="text" size="30" onkeyup="showResult(this.value, '<?php echo "$currHtag"; ?>' )">
        <div id="livesearch"></div>
        </form>

    </body>
</html>
