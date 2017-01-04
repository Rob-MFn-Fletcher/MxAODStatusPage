
function fillTable(data, tableID){
    var header = "<thead><tr>";
    header += "<th>Sample</th> <th>AOD AMI</th> <th>AOD Bookkeeper</th> <th>DAOD AMI</th> <th>DAOD Bookkeeper</th> <th>NevtsRunOverMxAOD</th> <th>NevtsPassedPreCutflowMxAOD</th> <th>NevtsIsPassedPreFlagMxAOD</th>";
    header += "</tr></thead>";
    $(tableID).append(header);
    $(tableID).append("<tbody>");

    for (var sample in data){
        var colorClass = "";
        if (sample['color'] === "red"){
            colorClass = "danger";
        }
        var tableRow = '<tr class="'+colorClass+'">';
        tableRow += "<td>"+ sample['sampleType'] + "</td>";
        tableRow += "<td>"+ sample['AOD_AMI'] + "</td>";
        tableRow += "<td>"+ sample['AOD_Bookkeeper'] + "</td>";
        tableRow += "<td>"+ sample['DAOD_AMI'] + "</td>";
        tableRow += "<td>"+ sample['DxAOD_Bookkeeper'] + "</td>";
        tableRow += "<td>"+ sample['NevtsRunOverMxAOD'] + "</td>";
        tableRow += "<td>"+ sample['NevtsPassedPreCutflowMxAOD'] + "</td>";
        tableRow += "<td>"+ sample['NevtsIsPassedPreFlagMxAOD'] + "</td>";
        tableRow += "</tr>";
        $(tableID).append(tableRow);
    }

    $(tableID).append("</tbody>")

}
$(document).ready(function(e){
    var htag = "<?php echo $currHtag; ?>";
    $.getJSON("../data/"+htag+"/ValidationTable_MC.json", function(result){
        fillTable(result, "#mc-table");
    });
    //$.getJSON("../data/"+htag+"/ValidationTable_Data.json", function(result){

    //});
});
