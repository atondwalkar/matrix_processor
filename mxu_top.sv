`timescale 1ns / 1ps

module mxu_top(
    clk,
    reset,
    awaddr,
    awready,
    awvalid,
    wdata,
    wstrb,
    wvalid,
    wready
    );
    
    parameter SIZE = 16;
    
    input logic clk, reset;
    
    input logic awready, awvalid;
    input logic [15:0] awaddr;
    
    input logic [3:0] wstrb;
    input logic [31:0] wdata;
    input logic wvalid, wready;
    
    logic load_en, mult_en, acc_en;
    
    logic [7:0] cache [SIZE*SIZE*2+6:0];
    // 0 - start
    // 1 - done
    // 2 - cycles
    // 3 - memsel
    // 4 - awaddr upper
    // 5 - awaddr lower
    // 6 - start of data
    
    control #(.SIZE(SIZE)) control_inst (
        .clk(clk),
        .reset(reset),
        .load_en(load_en),
        .mult_en(mult_en),
        .acc_en(acc_en),
        );
    
    array #(.SIZE(SIZE)) array_inst (
        .clk(clk),
        .reset(reset),
        .load_en(load_en),
        .mult_en(mult_en),
        .acc_en(acc_en),
        );
    
    always @ (clk)
    begin
        if(awvalid && awready)
        begin
            cache[4] <= awaddr[15:8];
            cache[5] <= awaddr[7:0];
        end
        else
        begin
            cache[4] <= cache[4];
            cache[5] <= cache[5];
        end
    end
    
endmodule
