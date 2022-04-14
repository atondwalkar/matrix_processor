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
    
    parameter SIZE = 4;
    
    input logic clk, reset, mult_en, acc_en, load_en;
    input logic [7:0] a_in [SIZE-1:0];
    input logic [7:0] b_in [SIZE-1:0];
    input logic [SIZE*SIZE-1:0] select;
    output logic [31:0] d_out;
    
    logic [7:0] a [SIZE:0][SIZE:0];
    logic [7:0] b [SIZE:0][SIZE:0];
    logic [7:0] acc_out [SIZE*SIZE-1:0];

    integer k;
    always_comb
    begin
        for(k=0; k<SIZE; k++)
        begin
            a[k][0] = a_in[k]; //row boundary
            b[0][k] = b_in[k]; //col boundary
        end
    end
    
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
