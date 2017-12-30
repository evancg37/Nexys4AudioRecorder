`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Arizona State University
// CSE320 Fall 2017
// Evan Greavu
// Audio Recorder Project
// deserialzer.sv
//////////////////////////////////////////////////////////////////////////////////

module Deserializer (
    input logic clock_i, // 100 Mhz system clock
    input logic enable_i, // Enable passed by Controller(~reset)
    
    output logic done_o, //Indicates that Data is ready
    output logic [15:0] data_o, //Output 16-bit Word

    output logic pdm_clk_o = 1'b0, //Modified clock to microphone
    input logic pdm_data_i, //Data from microphone
    output logic pdm_lrsel_o = 1'b0 //L/R select set to 0
);

logic [15:0] shift;
integer data_count = 0;

always_ff @ (posedge clock_i)
begin
    if (enable_i) begin
        pdm_clk_o = ~pdm_clk_o;
        if (done_o)
            done_o <= 1'b0;
                
        shift <= shift << 1; //Shift all data 1 to left
        shift[0] <= pdm_data_i; //The last digit is now new mic data

        data_count = data_count + 1;
        
        if (data_count > 15) begin //Data is done
             done_o <= 1'b1;
             data_o <= shift;
             data_count = 0;
        end
    end
end

endmodule