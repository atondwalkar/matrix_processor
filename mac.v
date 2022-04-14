`timescale 1ns / 1ps

//8b int multiplay accumulate unit

module mac(
    a,
    b,
    clk,
    mult_en,
    acc_en,
    reset,
    acc_out,
    x,
    y
    );
    
    input [7:0] a, b;
    input clk, mult_en, acc_en, reset;
    output reg [31:0] acc_out;
    output [7:0] x, y;
    
    reg [15:0] mult;
    
    always @ (posedge clk or posedge reset)
    begin
        if(reset)
        begin
            acc_out <= 32'b0;
            mult <= 16'b0;
        end
        else
        begin
            mult <= mult_en ? a*b : mult;
            acc_out <= acc_en ? mult + acc_out : acc_out;
        end
    end
    
    assign x = a;
    assign y = b;
    
    
endmodule
