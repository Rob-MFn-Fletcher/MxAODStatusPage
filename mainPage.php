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
    <body>

        <!---  Jumbotron header  -->
        <div id="jumbotron">
            <h2>
                <img class="higgs" src="/rfletche/MxAODsite/img/higgs.png">
                <p>HGam MxAOD Status<p>
                <img class="higgs" src="/rfletche/MxAODsite/img/higgs.png">
            </h2>
        </div>

        <!-- Navigation bar -->
        <nav class="navbar navbar-inverse">
            <div class="container-fluid">
                <div class="navbar-header">
                  <a class="navbar-brand" href="#">MxAOD Status</a>
                </div>
                <ul class="nav navbar-nav">
                    <li class="dropdown">
                        <a class="dropdown-toggle" data-toggle="dropdown" href="#">HTags
                        <span class="caret"></span></a>
                        <ul class="dropdown-menu" id="htags-dropdown">
                            <li id="default-htags"><a href="#">List populating...</a></li>
                        </ul>
                    </li>
                  <li><a href="#">Data Validation</a></li>
                </ul>

                <div class="nav navbar-nav navbar-right">
                    <form class="navbar-form navbar-right"  role="search">
                    <div class="input-group">
                        <input type="text" id="search-bar" class="form-control has-search-icon" placeholder="Search MxAODs" onkeyup="showResult(this.value, '<?php echo "$currHtag"; ?>' )">
                    </div>
                    </form>
                </div>
                <ul class="nav navbar-nav navbar-right">
                  <li><a><strong>Selected htag: <?php echo $currHtag;  ?></strong></a></li>
                </ul>

            </div>
        </nav>

        <div id="content">
            <div id="livesearch" class="col-md-6">

            </div>
            <div>
            Content ContentContentContentContentContentContentContentContentContentContentContentContentContentContentContentContentContentContentContentContentContentContentContentContentContentContentContentContentContent
            </div>
        </div>


    </body>
</html>
