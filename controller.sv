`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Arizona State University
// CSE320 Fall 2017
// Evan Greavu
// Audio Recorder Project
// controller.sv
//////////////////////////////////////////////////////////////////////////////////

module Controller (
    input logic clock,
    input logic clock_1mhz,
    input logic reset_button,
    
    input logic play_button,
    input logic record_button,
    input logic play_track_switch,
    input logic record_track_switch,
    
    output logic mic_enable,
    output logic speaker_enable,
    
    output logic [16:0] memory_address,
    output logic memory_write_a,
    output logic memory_write_b,
    output logic memory_ena_a,
    output logic memory_ena_b,
    
    input logic [15:0] memory_1_out,
    input logic [15:0] memory_2_out,
    output logic [15:0] memory_out,
    
    input logic deserializer_done,
    input logic serializer_done
);

logic ALWAYS_ENABLE = 1'b1;

typedef enum logic [2:0] {idle = 3'b000, record1 = 3'b001, record2 = 3'b010, play1 = 3'b011, play2 = 3'b100} states;

states STATE = idle;
states NEXT_STATE = idle;

logic [16:0] counting_address = 17'b0;

logic start_timer = 1'b0;
logic timer_finished;

Timer timer_2s (
    .clock(clock),
    .start(start_timer),
    .finished(timer_finished)
);

//State transition
always_ff @ (posedge clock)
begin
   if (reset_button)
        STATE <= idle;
    else 
        STATE <= NEXT_STATE;
end

logic internal_deserializer_flag;
logic internal_serializer_flag;

//State logic
always_ff @ (posedge clock)
begin
    if ((STATE  == record1 || STATE == record2) && deserializer_done) begin
        memory_write_a <= 1'b1;
        memory_write_b <= 1'b1;
    end
    else begin
        memory_write_a <= 1'b0;
        memory_write_b <= 1'b0;   
    end  
    if (STATE == idle) begin
        
        //Idle to play state
        if (play_button) begin
            if (! start_timer) 
                start_timer <= 1'b1; //Start timer
                        
            if (play_track_switch == 1'b0)
                NEXT_STATE <= play1; //Play track 1
    
            else if (play_track_switch == 1'b1)
                NEXT_STATE <= play2; //Play track 2
        end 
        
        else if (record_button) begin
            if (! start_timer) 
                start_timer <= 1'b1; //Start timer
                                       
            
            if (record_track_switch == 1'b0)  //Record track 1
                NEXT_STATE <= record1;
            else if (record_track_switch == 1'b1) //Record track 2
                NEXT_STATE <= record2;
            
        end else begin  //idle do nothing state
            counting_address <= 0;
            NEXT_STATE <= idle;
        end
    end 
    
    else begin
        if (start_timer) 
            start_timer <= #100 1'b0; //Timer should already be started
        
        if (timer_finished)
           NEXT_STATE <= idle;
        
        else if (STATE == record1)
            NEXT_STATE <= record1;
        else if (STATE == record2)
            NEXT_STATE <= record2;
        else if (STATE == play1) begin
            NEXT_STATE <= play1;
            memory_out <= memory_1_out;
        end
        else if (STATE == play2) begin
            NEXT_STATE <= play2;
            memory_out <= memory_2_out;
        end
        
        if (deserializer_done) begin
            if (! internal_deserializer_flag) begin //Shoddy way of creating an internal transition.
                counting_address <= counting_address + 1;  //Only increment the address once per deserializer_flag.
                internal_deserializer_flag <= 1'b1;
            end
        end else
            internal_deserializer_flag <= 1'b0;
            
        if (serializer_done) begin
            if (! internal_serializer_flag) begin
                counting_address <= counting_address + 1;
                internal_serializer_flag <= 1'b1;
            end
        end else
            internal_serializer_flag <= 1'b0;
    end
end
        
//Output controller logic
always_comb
begin
    case (STATE)
        idle: begin
            mic_enable = 1'b0;
            speaker_enable = 1'b0;
            memory_ena_a = 1'b0;
            memory_ena_b = 1'b0;
            memory_address = 17'b0;    
            mic_enable = 1'b0;
            speaker_enable = 1'b0; 
        end
        record1: begin
            memory_ena_a = 1'b1;
            memory_ena_b = 1'b0;         
            memory_address = counting_address;
            mic_enable = 1'b1;
            speaker_enable = 1'b0;
        end
        record2: begin
            memory_ena_a = 1'b0;
            memory_ena_b = 1'b1;   
            memory_address = counting_address;
            mic_enable = 1'b1;
            speaker_enable = 1'b0;
        end
        play1: begin
            memory_ena_a = 1'b1;
            memory_ena_b = 1'b0;   
            memory_address = counting_address;
            mic_enable = 1'b0;
            speaker_enable = 1'b1;
        end
        play2: begin
            memory_ena_a = 1'b0;
            memory_ena_b = 1'b1;   
            memory_address = counting_address;  
            mic_enable = 1'b0;
            speaker_enable = 1'b1;
        end
        default: begin
            mic_enable = 1'b0;
            speaker_enable = 1'b0;
            memory_ena_a = 1'b0;
            memory_ena_b = 1'b0;
            memory_address = 17'b0;    
            mic_enable = 1'b0;
            speaker_enable = 1'b0; 
        end
    endcase
end

endmodule
