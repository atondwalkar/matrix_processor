`timescale 1ns / 1ps

module array(
    a_in,
    b_in,
    mult_en,
    acc_en,
    load_en,
    clk,
    reset,
    select,
    d_out
    );
    
    input logic clk, reset, mult_en, acc_en, load_en;
    input logic [7:0] a_in, b_in;
    input logic [SIZE*SIZE-1:0] select;
    output logic [31:0] d_out;
    
    parameter SIZE = 16;
    
    logic [7:0] a [SIZE:0][SIZE:0];
    logic [7:0] b [SIZE:0][SIZE:0];
    logic [7:0] acc_out [SIZE*SIZE-1:0];
    
    assign a[0][0] = a_in;
    assign b[0][0] = b_in;
    
    genvar i, j;
    generate
    for (i=0; i<SIZE; i++)
    begin
        for (j=0; j<SIZE; j++) 
        begin
            mac element ( 
                .clk(clk), 
                .reset(reset), 
                .a_in(a[i][j]), 
                .b_in(b[i][j]), 
                .mult_en(mult_en), 
                .acc_en(acc_en), 
                .load_en(load_en), 
                .a_out(a[i+1][j+1]), 
                .b_out(b[i+1][j+1]),
                .acc_out(acc_out[i*SIZE+j])
                );
        end
    end 
    endgenerate
    
    assign d_out = acc_out[select];
    
endmodule
