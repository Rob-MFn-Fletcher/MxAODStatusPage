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
        <link rel="stylesheet" href="css/mystyle.css" />
    </head>
    <body bgcolor=white>
        <div id="jumbotron">
            <img class="higgs" src="/rfletche/MxAODsite/img/higgs.png">
            <h2> HGam MxAOD Status </h2>
            <img class="higgs" src="/rfletche/MxAODsite/img/higgs.png">
        </div>

        <div class="nav">
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
            <li id="currentTag"><a href="#">Selected htag: <?php echo $currHtag;  ?></a></li>
          </ul>
        </div>

        <div>
            <form>Search for your sample (click sample for specific sample page):
            <input type="text" size="30" onkeyup="showResult(this.value, '<?php echo "$currHtag"; ?>' )">
            <div id="livesearch"></div>
            </form>
        <div>

    </body>
</html>
