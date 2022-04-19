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
    wready,
    araddr,
    arready,
    arvalid,
    rready,
    rvalid,
    rdata
    );
    
    parameter SIZE = 16;
    
    input logic clk, reset;
    
    input logic awvalid;
    output logic awready;
    input logic [31:0] awaddr;
    
    input logic [3:0] wstrb;
    input logic [31:0] wdata;
    input logic wvalid;
    output logic wready;
    
    input logic arvalid;
    output logic arready;
    input logic [31:0] araddr;
    
    input logic arvalid;
    output logic arready;
    output logic [31:0] rdata;
    
    logic load_en, mult_en, acc_en;
    
    logic [7:0] cache [$clog2(SIZE*SIZE*2):0];
    // 0 - start/done
    // 1 - memsel
    //needs start, done, memsel, output
    
    //logic [7:0] control_reg [1:0];
    logic [31:0] write_reg;
    // 0 - awaddr upper
    // 1 - awaddr lower
    
    logic [31:0] read_reg;
    
    logic strb_sel;
    logic data_addr;
    logic [7:0] data_data;
    
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
        
        
    logic readstate;

    always @ (posedge clk)
    begin
        if(arvalid)
        begin
            arready <= 1;
            readstate <= 0;
        end
        else if (arvalid && arready)
        begin
            arready <= 0;
            read_reg <= awaddr;
            readstate <= 1;
        end
        else
        begin
            read_reg <= read_reg;
            readstate <= 0;
        end
    end
    
    assign select = read_reg[$clog2(SIZE*SIZE)-1:0];

    always @ (posedge clk)
    begin
        if(rvalid && readstate)
        begin
            rready <= 1;
        end
        else
        begin
            rready <= 0;
        end
    end
    
    assign rdata = d_out;
    
    always @ (posedge clk)
    begin
        if(awvalid)
        begin
            awready <= 1;
        end
        else if (awvalid && awready)
        begin
            awready <= 0;
            write_reg <= awaddr;
        end
        else
        begin
            write_reg <= write_reg;
        end
    end
   
    //assign data_addr = {control_reg[0][1:0], control_reg[1]};
    assign data_addr = write_reg[$clog2(SIZE*SIZE*2):0];
    
    always @ (posedge clk)
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
        else if (done)
        begin
            cache[0] <= 8'b0000_0010;
        end
        else
        begin
            cache[data_addr] <= cache[data_addr];
        end
    end
    
    //needs b channel
    
endmodule
