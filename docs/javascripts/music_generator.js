$(function(){
  window.ABCJS.midi.setSoundFont('/javascripts/');
  window.onload = function() {
    $(".music").each(function(){
      var id = $(this).attr("id");

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

      $("#edit-" + id).click(function() {
        $("#" + id).css("display", "block");
        $(this).hide();
      })
    })
  }
})
