var tabs = [
  "data15",
  "data16",
  "data16_iTS",
  "mc",
  "PhotonSys",
]

function fillTable(data, tableID){
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
$(document).ready(function(e){
    console.log(htag);


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
});
