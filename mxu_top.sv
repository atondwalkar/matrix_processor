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
    
    input logic awvalid;
    output logic awready;
    input logic [15:0] awaddr;
    
    input logic [3:0] wstrb;
    input logic [31:0] wdata;
    input logic wvalid;
    output logic wready;
    
    logic load_en, mult_en, acc_en;
    
    logic [7:0] cache [$clog2(SIZE*SIZE*2)-1:0];
    //needs start, done, memsel, output
    
    logic [7:0] control_reg [1:0];
    // 0 - awaddr upper
    // 1 - awaddr lower
    
    logic strb_sel;
    logic data_addr;
    logic [7:0] data_data;
    
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
        if(awvalid)
        begin
            awready <= 1;
        end
        else if (awvalid && awready)
        begin
            awready <= 0;
            control_reg[0] <= awaddr[15:8];
            control_reg[1] <= awaddr[7:0];
        end
        else
        begin
            control_reg[0] <= control_reg[0];
            control_reg[1] <= control_reg[1];
        end
    end
   
    assign data_addr = {control_reg[0][1:0], control_reg[1]};
    
    always @ (clk)
    begin
        if(wvalid)
        begin
            wready <= 1;
            casez (wstrb)
                4'b1??? : data_data <= wdata[31:24];
                4'b01?? : data_data <= wdata[23:16];
                4'b001? : data_data <= wdata[15:8];
                4'b0001 : data_data <= wdata[7:0];
                default : data_data <= 8'b1000_0001;
            endcase
        end
        else if (wvalid && wready)
        begin
            wready <= 0;
            cache[data_addr] <= data_data;
        end
        else
        begin
            cache[data_addr] <= data_data;
        end
    end
    
endmodule
