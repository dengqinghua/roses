$(function(){
  $(".pdf_doc").each(function(){
    var docName = $(this).attr("docname");
    var show = $(this).attr("show");

    if ((show == "true") || (window.location.search.includes("s=t")) || (window.location.host.includes('127.0.0.1'))) {
      $(this).css("display", "block");
      var host = window.location.origin;
      // $(this).append("<embed src='https://drive.google.com/viewerng/viewer?embedded=true&url=" + url + "' style='width:100%; height:650px;'>");
      var url = "/javascripts/pdf.js/web/viewer.html?file=" + host + "/doc/" + docName + ""
      // $(this).append("<embed src= " + url + " style='width:100%; height:1000px;'>");
      $(this).append("<a href=" + url + " target='_blank'>"+ "PDF: " + docName + "</a>");
    }
  })
})
