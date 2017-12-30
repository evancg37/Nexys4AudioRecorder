`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Arizona State University
// CSE320 Fall 2017
// Evan Greavu
// Audio Recorder Project
// synchronizer.sv
//////////////////////////////////////////////////////////////////////////////////

module Synchronizer (
    input logic clock,
    input logic reset_button,
    
    input logic play_button,
    input logic record_button,
    input logic play_track_switch,
    input logic record_track_switch,
    
    output logic sync_reset_button,
    output logic sync_play_button,
    output logic sync_record_button,
    output logic sync_play_track_switch,
    output logic sync_record_track_switch
);

always_ff @ (posedge clock)
begin
   sync_record_button <= record_button;
   sync_play_button <= play_button;
   sync_reset_button <= reset_button;
   sync_play_track_switch <= play_track_switch; 
   sync_record_track_switch <= record_track_switch; 
end

endmodule
