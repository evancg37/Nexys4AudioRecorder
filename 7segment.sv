`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Arizona State University
// CSE320 Fall 2017
// Evan Greavu
// Audio Recorder Project
// 7segment.sv
//////////////////////////////////////////////////////////////////////////////////

module seven_segment_display (
    input logic clock,

    input logic record_track_switch,
    input logic play_track_switch,
    
    output logic [6:0] cathode,
    output logic [7:0] anode
);

parameter LED_FREQUENCY = 50000;

integer clock_count = 0;
logic internal_clock = 1'b0;

logic internal_alternator = 1'b0;

always_ff @ (posedge clock) //Integer-count clock chopper
begin
    clock_count = clock_count + 1;
    if (clock_count >= LED_FREQUENCY / 2) begin
        internal_clock = ~internal_clock;
        clock_count = 0;
    end
end

always_ff @ (posedge internal_clock)
begin
    internal_alternator <= ~internal_alternator;
    
    if (internal_alternator == 1'b0) begin //Update record LED, anode 0
        anode <= 8'b11111110;
        if (record_track_switch == 1'b0)
            //display 1 on the record number, anode 0
            cathode <= 7'h79;
        else
            //display 2 on the record number, anode 0
            cathode <= 7'h24;
     end
     else begin
        anode <= 8'b11111101;
        if (play_track_switch == 1'b0)
            //display 1 on the play number, anode 1
            cathode <= 7'h79;
        else
            //display 2 on the play number, anode 1
            cathode <= 7'h24;
     end
end
  
endmodule
