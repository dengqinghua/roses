$(function(){
  $(".diagrams").each(function(){
    text = $(this).text();
    $(this).text("");
    $(this).css("display", "block");
    var id = $(this).attr("id");
    var diagram = Diagram.parse(text);
    diagram.drawSVG(id, {theme: 'hand'});
  })
})
