`timescale 1ns / 1ps

//8b int multiplay accumulate unit

module mac(
    a_in,
    b_in,
    clk,
    mult_en,
    acc_en,
    load_en,
    reset,
    acc_out,
    a_out,
    b_out
    );
    
    input [7:0] a_in, b_in;
    input clk, mult_en, acc_en, load_en, reset;
    output reg [31:0] acc_out;
    output reg [7:0] a_out, b_out;
    
    reg [15:0] mult;
    
    always @ (posedge clk or posedge reset)
    begin
        if(reset)
        begin
            a_out <= 0;
            b_out <= 0;
            acc_out <= 32'b0;
            mult <= 16'b0;
        end
        else
        begin
            a_out <= load_en ? a_in : a_out;
            b_out <= load_en ? b_in : b_out;
            mult <= mult_en ? a_out*b_out : mult;
            acc_out <= acc_en ? mult + acc_out : acc_out;
        end
    end 
    
endmodule
