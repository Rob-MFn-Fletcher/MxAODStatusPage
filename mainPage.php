<html>
    <html lang="en">
    <head>
        <meta charset="utf-8" />
        <?php
            include("../html/vars.php");
            $currHtag=$_GET["h"];
        ?>
        <!--  External links  -->
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>

        <!--  Local stuff -->
        <script type="text/javascript" src="js/livesearch.js"></script>
        <script type="text/javascript" src="js/navbar.js"></script>
        <title>HGam MxAOD Status</title>
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





        <nav class="navbar navbar-inverse navbar-fixed-top">
            <div class="container-fluid">
                <div class="navbar-header">
                  <a class="navbar-brand" href="#">WebSiteName</a>
                </div>
                <ul class="nav navbar-nav">
                  <li class="active"><a href="#">Home</a></li>
                  <li><a href="#">Page 1</a></li>
                  <li><a href="#">Page 2</a></li>
                  <li><a href="#">Page 3</a></li>
                </ul>
            </div>
        </nav>



<!--
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
-->
        <p> Selected htag: <?php echo $currHtag;  ?> </p>


        <form>Search for your sample (click sample for specific sample page):
        <input type="text" size="30" onkeyup="showResult(this.value, '<?php echo "$currHtag"; ?>' )">
        <div id="livesearch"></div>
        </form>

    </body>
</html>
