`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Arizona State University
// CSE320 Fall 2017
// Evan Greavu
// Audio Recorder Project
// timer.sv
//////////////////////////////////////////////////////////////////////////////////

module Timer (
    input logic clock,
    input logic start,
    
    output logic finished = 1'b0
);

parameter cycles_2_seconds = 200000000;

logic counting = 1'b0;
    
integer count = 0;

always_ff @ (posedge clock)
begin
    if (start) begin
        finished <= 1'b0;
        counting <= 1'b1;
    end
    
    if (counting) begin
        count = count + 1;
        if (count >= cycles_2_seconds) begin
            count = 0;
            counting <= 1'b0;
        end
    end 
    else
        finished <= 1'b1;
end

endmodule
