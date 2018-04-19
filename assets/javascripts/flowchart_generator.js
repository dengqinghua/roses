$(function(){
  $(".flowchart").each(function(){
    var code = $(this).text();
    $(this).text("");
    var id = $(this).attr("id");

    $(this).css("display", "block");
    $(this).css("text-align", "center");
    flowchart.parse(code).drawSVG(id);
  })
})
