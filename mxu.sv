`timescale 1ns / 1ps

module mxu(
    clk,
    reset,
    wdata,
    awaddr,
    wready,
    rdata,
    araddr,
    );
    
    parameter SIZE = 16;
    
    input logic clk, reset;

    input logic [31:0] awaddr;
    input logic [8:0] wdata;
    output logic wready;
    
    input logic [31:0] araddr;
    output logic [31:0] rdata;
    
    logic load_en, mult_en, acc_en;
    
    logic [7:0] cache [$clog2(SIZE*SIZE*2):0];
    // start will be 8'b0000_0001
    // done will be 8'b0000_0010
    // 0 - start/done
    // rest is data
    
    logic done;
    
    logic select [$clog2(SIZE*SIZE)-1:0];
    logic [31:0] d_out;
    
    control #(.SIZE(SIZE)) control_inst (
        .clk(clk),
        .reset(reset),
        .load_en(load_en),
        .mult_en(mult_en),
        .acc_en(acc_en),
        .done(done),
        .start(cache[0][0])
        );
    
    array #(.SIZE(SIZE)) array_inst (
        .clk(clk),
        .reset(reset),
        .load_en(load_en),
        .mult_en(mult_en),
        .acc_en(acc_en),
        .select(select),
        .d_out(d_out)
        );
        
    assign select = araddr[$clog2(SIZE*SIZE)-1:0];
    assign rdata = d_out;
        
    always @ (posedge clk)
    begin
        if(done)
        begin
            cache[0] <= 8'b0000_0010;
        end
        else if(wready)
        begin
            cache[awaddr[$clog2(SIZE*SIZE*2):0]] <= wdata;
        end
        else
        begin
            cache[awaddr[$clog2(SIZE*SIZE*2):0]] <= cache[awaddr[$clog2(SIZE*SIZE*2):0]];
        end
    end
        
        
endmodule
