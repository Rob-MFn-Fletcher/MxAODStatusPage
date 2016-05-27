use update script to update everything on the site for a particular MxAOD release.  
e.g. source update.sh h011

check out the setup script (setup.sh) for things to change like:
  dataset directory on EOS
  variables that are plotted
  change in cutflow variables
  
An Explanation of the files and folders in the main www/ folder:
  AllCutflows
    As expected, it holds the scripts that make the cutflows for the new release, 
    and the scripts used to compare variables between samples on the website
  fileSize
    this holds the scripts to give the file size stats.  Currently not used on site.
  html
    holds the navigation bar and PHP variables used by all of the PHP scripts. Very little html.
  img
    most important folder of the site, holds the higgs man image.
  index.php
    landing page of the site, redirects to last release it finds
  liveSearch
    holds the nuts and bolts of the awesome search function. 
  mainPage.php
    home page for each htag release.  Has livesearch function.
  mystyle.css
    css style magic file.  Has formatting of html types for the site.
  plotter
    has the scripts for making all of the kinematic variable plots for each dataset, as
    well as the scripts and php that create comparisons on-the-fly
  README
    the file you are currently looking at.  Describes the parts of the site.
  samplePage
    PHP that creates the individual sample pages.  Calls scripts to do cutflow, variable, and 
    plot comparisons.
  setup.sh
    contains setup and configuration for the site.
  tmp
    folder that holds the variable plot comparisons that are created by the webserver in plotter/comparePlots.sh
    Delete everything in here before it gets too big.
  update.sh
    update script to update the entire site (minus the sample validation page) for a new release.
  variables
    has the scripts for making the variable lists for each sample, as well as the scripts
    for on-the-fly comparison of variables in samples
