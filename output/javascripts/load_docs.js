$(function(){
  $(".google_doc").each(function(){
    var url = $(this).attr("url");
    $(this).css("display", "block");
    $(this).append("<embed src='https://drive.google.com/viewerng/viewer?embedded=true&url=" + url + "' style='width:100%; height:650px;'>");
  })
})
