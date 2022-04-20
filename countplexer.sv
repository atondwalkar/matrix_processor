`timescale 1ns / 1ps

module countplexer(
    clk,
    reset,
    enable,
    next,
    data_in,
    data_out
    );
    
    parameter SIZE = 4;

    input logic clk, reset, enable, next;
    input logic [SIZE-1:0][7:0] data_in;
    output logic [7:0] data_out;
    
    logic [SIZE-1:0] count;
    
    initial
    begin
        count <= 0;
    end
    
    always @ (posedge clk)
    begin
        if(reset)
        begin
            count <= 0;
        end
        else if(enable & next)
        begin
            count <= count + 1;
        end
        else
        begin
            count <= count;
        end
    end

    assign data_out = enable ? data_in[count] : 8'b0000_0000;

endmodule