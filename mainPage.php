<html>
    <html lang="en">
    <head>
        <meta charset="utf-8" />
        <!--
        <?php
            include("../html/vars.php");
            $currHtag=$_GET["h"];
        ?>
        -->
        <!-- Global Variable to hold the current H tag. Think of a way to do this without a global. Might be a little better. -->
        <script type="text/javascript">
            var currHtag = "h013";
        </script>
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
                HGam MxAOD Status
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
                        <input type="text" id="search-bar" class="form-control has-search-icon" placeholder="Search MxAODs" onkeyup="showResult(this.value, currHtag )">
                    </div>
                    </form>
                </div>
                <ul class="nav navbar-nav navbar-right">
                  <li id="current-Htag"></li>
                </ul>
                <div id="livesearch" class="col-md-6"> </div>
            </div>
        </nav>

        <!--%%%%%%%%%  Main Page Content  %%%%%%%%%-->
        <div id="content">
            <div id="cutflow-container">
                <h1>Cutflow</h1>
            </div>
            <div id="plots-container">
                <h1>Comparison Plots</h1>
            </div>
        </div>


    </body>
</html>
