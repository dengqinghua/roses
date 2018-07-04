$(function(){
  window.onload = function() {
    $(".music").each(function(){
      var id = $(this).attr("id");
      //$(this).css("display", "block");

      new ABCJS.Editor(id, {
        canvas_id: "canvas-" + id,
        generate_midi: true,
        midi_id: "midi-" + id ,
        abcjsParams: {
          generateInline: true,
          responsive: "resize",
          generateDownload: false,
          inlineControls: {
            tempo: true,
          },
        }
      });
    })
  }
})
