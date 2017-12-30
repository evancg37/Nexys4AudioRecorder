`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Arizona State University
// CSE320 Fall 2017
// Evan Greavu
// Audio Recorder Project
// serializer.sv
//////////////////////////////////////////////////////////////////////////////////


module Serializer (
    input logic clock_i,
    input logic enable_i,
    
    output logic done_o, //Indicates that Data is sent
    input logic [15:0] Data_i, //Input 16-bit word

    output logic pwm_audio_o, //Output audio data
    output logic pwm_sdaudio_o = 1'b1, // Output audio enable (package pin D12),keep high 
    
    output logic voice_indicator
    
);

parameter THRESHOLD = 56;

integer data_clock = 0;

logic [15:0] shift;

integer clock_count = 0;

//BONUS FEATURE: Loudness indicator
integer pwm_high_count = 0;
integer pwm_clock_count = 0;

always_ff @ (posedge clock_i) begin
    if (enable_i) begin //If we are in the playing state
        pwm_clock_count = pwm_clock_count + 1;
        if (pwm_audio_o)
            pwm_high_count = pwm_high_count + 1;
            
        if (pwm_clock_count > 100) begin
            if (pwm_high_count >= THRESHOLD)
                voice_indicator <= 1'b1;
            else
                voice_indicator <= 1'b0;
            pwm_high_count = 0;
            pwm_clock_count = 0;
        end
    end
    else
        voice_indicator <= 1'b0;
end

initial
    pwm_sdaudio_o = 1'b1;
    
always_ff @ (posedge clock_i)
begin
    if (enable_i) begin
        //Shift out digits
        if (done_o)
            done_o <= 1'b0;
        
        shift = shift >> 1;
        pwm_audio_o <= shift[0];
        shift[15] = Data_i[data_clock];       
        data_clock = data_clock + 1; //Increment the digit of data
        
        if (data_clock > 15) //Data is done
            done_o <= 1'b1;
    end
end

endmodule
