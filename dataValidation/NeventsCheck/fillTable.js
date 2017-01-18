
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
       // tableRow += '<td class="col-md-3 col-lg-4">'+ sample['sampleType'] + '</td>';
       // tableRow += '<td class="col-md-1 col-lg-1">'+ sample['AOD_AMI'] + '</td>';
       // tableRow += '<td class="col-md-1 col-lg-1">'+ sample['AOD_Bookkeeper'] + '</td>';
       // tableRow += '<td class="col-md-1 col-lg-1">'+ sample['DAOD_AMI'] + '</td>';
       // tableRow += '<td class="col-md-1 col-lg-1">'+ sample['DxAOD_Bookkeeper'] + '</td>';
       // tableRow += '<td class="col-md-1 col-lg-1">'+ sample['NevtsRunOverMxAOD'] + '</td>';
       // tableRow += '<td class="col-md-1 col-lg-1">'+ sample['NevtsPassedPreCutflowMxAOD'] + '</td>';
       // tableRow += '<td class="col-md-1 col-lg-1">'+ sample['NevtsIsPassedPreFlagMxAOD'] + '</td>';

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
    $.getJSON("data/"+htag+"/ValidationTable_MC.json", function(result){
        fillTable(result, "#mc-table");
        $("#mc-table").floatThead({
            position: 'fixed'
            //scrollContainer: function($table){
            //return $table.closest(".table-container");
            //}
        });
        $("#mc-table").floatThead('reflow');
    });
    $.getJSON("data/"+htag+"/ValidationTable_data15.json", function(result){
        fillTable(result, "#data15-table");
        $("#data15-table").floatThead({
            position: 'fixed'
            //scrollContainer: function($table){
            //return $table.closest(".table-container");
            //}
        });
        $("#data15-table").floatThead('reflow');
    });
    $.getJSON("data/"+htag+"/ValidationTable_data16.json", function(result){
        fillTable(result, "#data16-table");
        $("#data16-table").floatThead({
            position: 'fixed'
            //scrollContainer: function($table){
            //return $table.closest(".table-container");
            //}
        });
        $("#data16-table").floatThead('reflow');
    });
});
