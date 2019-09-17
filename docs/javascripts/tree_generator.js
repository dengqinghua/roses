$(function(){
  $(".tree_chart").each(function(){
    json = $(this).text();
    $(this).text("");
    $(this).css("display", "block");
    new Treant(JSON.parse(json));
  })
})
