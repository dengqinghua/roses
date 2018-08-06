"use strict";

/* eslint no-var:0, vars-on-top:0 */
/* global Tonal, SVG, Tone, axios */

//
// set up tone.js audio
//

var envelope = {
  attack: 0.01,
  decay: 4.0,
  sustain: 0.01,
  release: 1
};

// create array of 6x Tone.Synth
var synth = [];
for (var i = 0; i < 6; i++) {
  synth[i] = new Tone.Synth({
    oscillator: {
      type: "triangle8"
    },
    envelope: envelope
  });
}

function setPlayEvent(play, notes, timing) {
  play.setAttribute("data-notes", notes);
  play.addEventListener("mousedown", function (e) {
    var notesPlayString = e.target.getAttribute("data-notes");
    var notesPlay = notesPlayString.split(":");
    playNotes(notesPlay, timing);
  });
}

function playNotes(notes, time) {
  var _loop = function _loop(j) {
    synth[j].toMaster();
    setTimeout(function () {
      synth[j].triggerAttackRelease(notes[j], 2);
    }, j * time + 0.1);
  };

  for (var j = 0; j < notes.length; j++) {
    _loop(j);
  }
}

$(function(){
  $(".chordSvg").each(function(){
    var svg = new ChordySvg(
      {
      shape: $(this).attr("data-shape"),
      root: $(this).attr("data-root"),
      name: $(this).attr("data-name")
    },
    { target: this });

    var notes = svg.notes().join(":");
    var play_arpeggio = $(this).siblings(".play").children(".play-arpeggio").get(0),
        play_strum    = $(this).siblings(".play").children(".play-strum").get(0),
        play_tone     = $(this).siblings(".play").children(".play-tone").get(0);

    setPlayEvent(play_arpeggio, notes, 300);
    setPlayEvent(play_strum, notes, 100);
    setPlayEvent(play_tone, notes, 0);
  })
})
