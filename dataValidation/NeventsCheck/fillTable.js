
function fillTable(data, tableID){
    var header = '<thead><tr>';
    header += '<th class="col-sm-3">Sample/Run Number</th> <th class="col-sm-1">AOD AMI</th> <th class="col-sm-1">AOD Bookkeeper</th> <th class="col-sm-1">DAOD AMI</th> <th class="col-sm-1">DAOD Bookkeeper</th> <th class="col-sm-1">Evts Run MxAOD</th> <th class="col-sm-1">Pass Pre Cutflow MxAOD</th> <th class="col-sm-1">IsPassedPre Flag MxAOD</th>';
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
        tableRow += '<td class="col-sm-3">'+ sample['sampleType'] + '</td>';
        tableRow += '<td class="col-sm-1">'+ sample['AOD_AMI'] + '</td>';
        tableRow += '<td class="col-sm-1">'+ sample['AOD_Bookkeeper'] + '</td>';
        tableRow += '<td class="col-sm-1">'+ sample['DAOD_AMI'] + '</td>';
        tableRow += '<td class="col-sm-1">'+ sample['DxAOD_Bookkeeper'] + '</td>';
        tableRow += '<td class="col-sm-1">'+ sample['NevtsRunOverMxAOD'] + '</td>';
        tableRow += '<td class="col-sm-1">'+ sample['NevtsPassedPreCutflowMxAOD'] + '</td>';
        tableRow += '<td class="col-sm-1">'+ sample['NevtsIsPassedPreFlagMxAOD'] + '</td>';
        tableRow += '</tr>';
        $(tableID).append(tableRow);
    }

    $(tableID).append("</tbody>")

}
$(document).ready(function(e){
    console.log(htag);
    $.getJSON("data/"+htag+"/ValidationTable_MC.json", function(result){
        fillTable(result, "#mc-table");
    });
    $.getJSON("../data/"+htag+"/ValidationTable_Data.json", function(result){
        fillTable(result, "data15-table");
    });
    $.getJSON("../data/"+htag+"/ValidationTable_Data.json", function(result){
        fillTable(result, "data16-table");
    });
});
