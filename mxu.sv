`timescale 1ns / 1ps

module mxu(
    clk,
    reset,
    wdata,
    awaddr,
    wready,
    awready,
    rdata,
    araddr,
    );
    
    parameter SIZE = 4;
    
    input logic clk, reset;

    input logic [31:0] awaddr;
    input logic [8:0] wdata;
    input logic wready;
    input logic awready;
    
    input logic [31:0] araddr;
    output logic [31:0] rdata;
    
    logic load_en, mult_en, acc_en;
    logic [SIZE-1:0] memsel;
    
    logic [SIZE*SIZE*2:0][7:0] cache;
    // start will be 8'b0000_0001
    // done will be 8'b0000_0010
    // 0 - start/done
    // rest is data
    
    logic done, next;
    
    logic [$clog2(SIZE*SIZE)-1:0] select;
    logic [31:0] d_out;
    
    logic reset_plex;
    logic [SIZE-1:0][SIZE-1:0][7:0] data_plex_a;
    logic [SIZE-1:0][SIZE-1:0][7:0] data_plex_b;
    logic [SIZE-1:0][7:0] a_in;
    logic [SIZE-1:0][7:0] b_in;
    
    assign reset_plex = reset | done;
    
    integer x, y;
    always_comb
    begin
        for(x=0; x<SIZE; x=x+1)
        begin
            for(y=0; y<SIZE; y=y+1)
            begin
                data_plex_a[x][y] <= cache[x*SIZE+y + 1];
                data_plex_b[x][y] <= cache[x*SIZE+y + SIZE*SIZE + 1];
            end
        end
    end
    
    genvar i;
    generate
    for(i=0; i<SIZE; i=i+1)
    begin
        countplexer #(.SIZE(SIZE)) plex_a (
            .clk(clk),
            .reset(reset_plex),
            .enable(memsel[i]),
            .next(next),
            .data_in(data_plex_a[i]),
            .data_out(a_in[i])
            );
        countplexer #(.SIZE(SIZE)) plex_b (
            .clk(clk),
            .reset(reset_plex),
            .enable(memsel[i]),
            .next(next),
            .data_in(data_plex_b[i]),
            .data_out(b_in[i])
            );
    end
    endgenerate
    
    control #(.SIZE(SIZE)) control_inst (
        .clk(clk),
        .reset(reset),
        .load_en(load_en),
        .mult_en(mult_en),
        .acc_en(acc_en),
        .done(done),
        .start(cache[0][0]),
        .memsel(memsel),
        .next(next)
        );
    
    array #(.SIZE(SIZE)) array_inst (
        .clk(clk),
        .reset(reset),
        .load_en(load_en),
        .mult_en(mult_en),
        .acc_en(acc_en),
        .select(select),
        .d_out(d_out),
        .a_in(a_in),
        .b_in(b_in)
        );
        
    assign select = araddr[$clog2(SIZE*SIZE)-1:0];
    assign rdata = d_out;
        
    always @ (posedge clk)
    begin
        if(done)
        begin
            cache[0] <= 8'b0000_0010;
        end
        else if(wready & awready)
        begin
            cache[awaddr[$clog2(SIZE*SIZE*2):0]] <= wdata;
        end
        else
        begin
            cache[awaddr[$clog2(SIZE*SIZE*2):0]] <= cache[awaddr[$clog2(SIZE*SIZE*2):0]];
        end
    end
        
        
endmodule
