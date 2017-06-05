function fillTable(data, tableID){
    console.log("In fillTable with ID: "+tableID);
    var header = '<thead><tr>';
    header += '<th class="col-md-3 col-lg-4">Sample/Run Number</th> ';
    header += '<th class="col-md-1 col-lg-1">AOD AMI</th> ';
    header += '<th class="col-md-1 col-lg-1">AOD Bookkeeper</th> ';
    header += '<th class="col-md-1 col-lg-1">DAOD AMI</th> ';
    header += '<th class="col-md-1 col-lg-1">DAOD Bookkeeper</th> ';
    header += '<th class="col-md-1 col-lg-1">Evts Run MxAOD</th> ';
    header += '<th class="col-md-1 col-lg-1">Pass Pre Cutflow MxAOD</th> ';
    header += '<th class="col-md-1 col-lg-1">IsPassedPre Flag MxAOD</th>';
    header += '</tr></thead>';
    $(tableID).append(header);
    $(tableID).append('<tbody>');

    for (var entry in data){
        var sample = data[entry];
        var colorClass = 'default';
        if (sample['color'] === "red"){
            colorClass = "my-danger";
        }
        var tableRow = '<tr class="'+colorClass+'">';

        tableRow += '<td>'+ sample['sampleType'] + '</td>';
        tableRow += '<td>'+ sample['AOD_AMI'] + '</td>';
        tableRow += '<td>'+ sample['AOD_Bookkeeper'] + '</td>';
        tableRow += '<td>'+ sample['DAOD_AMI'] + '</td>';
        tableRow += '<td>'+ sample['DxAOD_Bookkeeper'] + '</td>';
        tableRow += '<td>'+ sample['NevtsRunOverMxAOD'] + '</td>';
        tableRow += '<td>'+ sample['NevtsPassedPreCutflowMxAOD'] + '</td>';
        tableRow += '<td>'+ sample['NevtsIsPassedPreFlagMxAOD'] + '</td>';

        tableRow += '</tr>';
        $(tableID).append(tableRow);
    }

    $(tableID).append("</tbody>")

}

function createTable(tabs){
  // Function to create all of the html elements needed for each tab on the
  // validation page.
  // tabs should be a list of tab names to include. i.e. data15
  var tabsList = '<ul>';
  for(var i in tabs){
    var tabName = tabs[i];
    tabsList += '<li><a href="#'+ tabName +'-container">'+tabName+'</a></li>';
  }
  tabsList += '</ul>';
  $('#tabs').append(tabsList);

  for(var i in tabs){
    var tabName = tabs[i];
    var tabDiv = '<div id="'+ tabName +'-container" class="tab-container">';
    tabDiv += '<h2>'+tabName+'</h2>'; 
    tabDiv+=  '     <div class="col-sm-6 missing-samples">  ';
    tabDiv+='          <div class="missing-samples-content"> ';
    tabDiv+='          <h3> Missing Data Samples </h3>  ';
    tabDiv+='          </div>  ';
    tabDiv+='      </div>  ';
    tabDiv+='      <div class="col-sm-6 missing-input">  ';
    tabDiv+='          <div class="missing-input-content"> '; 
    tabDiv+='          <h3> Missing input</h3>  ';
    tabDiv+='          </div>  ';
    tabDiv+='      </div>  ';
    tabDiv+='      <div class="table-container container">  ';
    tabDiv+='          <table class="table table-hover" id="'+tabName+'-table" >  ';
    tabDiv+='          </table>  ';
    tabDiv+='      </div>  ';
    tabDiv+='  </div>';

    $('#tabs').append(tabDiv);
    console.log("Created div for: "+tabName+"-table");
  }
}

$(document).ready(function(e){
    console.log(htag);
    // Get the list of files that start with 'ValidationTable' from the proper directory.
    $.getJSON("../html/fileList.php?h="+htag, function(result){
          // result will be a json encoded string with file paths to all
          // validation table results in the form  ../dataValidation/data/h015b/ValidationTable_FlavorAllSys1.json
          var tabNames = [];
          //console.log(result[0]);
          for(var i in result){
            console.log(result[i]);
            console.log(result[i].match(".*ValidationTable_(.*)\.json")[1]);
            tabNames.push(result[i].match(".*ValidationTable_(.*)\.json")[1]);
          }
          console.log(tabNames);

          // Create the needed HTML elements on the page.
          createTable(tabNames);

          // Fill the proper elements.
          for (var i in result){
            var vfile = result[i]
            // Need to make this file path relative to this one.
            var file_url = vfile.replace('../dataValidation/','');
            console.log("Getting json file: "+file_url);
            var tableID = '#'+vfile.match(".*ValidationTable_(.*)\.json")[1]+'-table';
            //console.log("TableID: "+tableID)
            $.getJSON(file_url, (function(tableID){
                return function(thing){
                    // Fill the table we just created.
                    console.log("Calling fillTable with: "+tableID);
                    fillTable(thing, tableID);
                    $(tableID).floatThead({
                        position: 'fixed'
                    });
                    $(tableID).floatThead('reflow');
                };
            })(tableID));
          }

    $('#tabs').tabs();
    });


    /*

    $.getJSON("data/"+htag+"/ValidationTable_mc15c.json", function(result){
        fillTable(result, "#mc-table");
        $("#mc-table").floatThead({
            position: 'fixed'
        });
        $("#mc-table").floatThead('reflow');
    });
    $.getJSON("data/"+htag+"/ValidationTable_data15.json", function(result){
        fillTable(result, "#data15-table");
        $("#data15-table").floatThead({
            position: 'fixed'
        });
        $("#data15-table").floatThead('reflow');
    });
    $.getJSON("data/"+htag+"/ValidationTable_data16.json", function(result){
        fillTable(result, "#data16-table");
        $("#data16-table").floatThead({
            position: 'fixed'
        });
        $("#data16-table").floatThead('reflow');
    });
    $.getJSON("data/"+htag+"/ValidationTable_data16_iTS.json", function(result){
        fillTable(result, "#data16_iTS-table");
        $("#data16_iTS-table").floatThead({
            position: 'fixed'
        });
        $("#data16_iTS-table").floatThead('reflow');
    });
    $.getJSON("data/"+htag+"/ValidationTable_PhotonSys.json", function(result){
        fillTable(result, "#PhotonSys-table");
        $("#PhotonSys-table").floatThead({
            position: 'fixed'
        });
        $("#PhotonSys-table").floatThead('reflow');
    });
    $.getJSON("data/"+htag+"/ValidationTable_JetSys.json", function(result){
        fillTable(result, "#JetSys-table");
        $("#JetSys-table").floatThead({
            position: 'fixed'
        });
        $("#JetSys-table").floatThead('reflow');
    });
    $.getJSON("data/"+htag+"/ValidationTable_LeptonMETSys.json", function(result){
        fillTable(result, "#LeptonMETSys-table");
        $("#LeptonMETSys-table").floatThead({
            position: 'fixed'
        });
        $("#LeptonMETSys-table").floatThead('reflow');
    });
    $.getJSON("data/"+htag+"/ValidationTable_PhotonAllSys.json", function(result){
        fillTable(result, "#PhotonAllSys-table");
        $("#PhotonAllSys-table").floatThead({
            position: 'fixed'
        });
        $("#PhotonAllSys-table").floatThead('reflow');
    });
    */
});
