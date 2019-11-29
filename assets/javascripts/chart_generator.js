$(function(){
  $(".charts").each(function(){
    json = $(this).text();
    var id = $(this).attr("hex_id");
    var ctx = document.getElementById(id).getContext('2d');
    var myChart = new Chart(ctx, JSON.parse(json))
  })
})
