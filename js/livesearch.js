
function showResult(str,currHtag) {
  if (str.length==0) {
    $("#livesearch").innerHTML="";
    return;
  }
  if (window.XMLHttpRequest) {
    // code for IE7+, Firefox, Chrome, Opera, Safari
    xmlhttp=new XMLHttpRequest();
  } else {  // code for IE6, IE5
    xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
  }
  xmlhttp.onreadystatechange=function() {
    if (xmlhttp.readyState==4 && xmlhttp.status==200) {
      document.getElementById("livesearch").innerHTML=xmlhttp.responseText;
      //document.getElementById("livesearch").style.border="1px solid #A5ACB2";
      $('#livesearch').slideDown(500);
    }
  }
  xmlhttp.open("GET","liveSearch/livesearch.php?q="+str+"&h="+currHtag,true);
  xmlhttp.send();
}
