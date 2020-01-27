$(function(){
  $(".pdf_doc").each(function(){
    var docName = $(this).attr("docname");
    $(this).css("display", "block");
    var host = window.location.origin;
    // $(this).append("<embed src='https://drive.google.com/viewerng/viewer?embedded=true&url=" + url + "' style='width:100%; height:650px;'>");
    var url = "/javascripts/pdf.js/web/viewer.html?file=" + host + "/doc/" + docName + ""
    $(this).append("<embed src= " + url + " style='width:100%; height:650px;'>");
    $(this).append("<a href=" + url + " target='_blank'>View</a>");
  })
})
