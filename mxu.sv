`timescale 1ns / 1ps

module mxu(
    clk,
    reset,
    wdata,
    awaddr,
    wready,
    rdata,
    araddr,
    arready
);

    parameter SIZE = 4;

    input logic clk, reset;

    input logic [31:0] awaddr;
    input logic [8:0] wdata;
    input logic wready;
    input logic arready;

    input logic [31:0] araddr;
    output logic [31:0] rdata;

    logic [31:0] ar_bus;

    logic load_en, mult_en, acc_en;
    logic [SIZE-1:0] memsel;

    logic [SIZE*SIZE*2 + 1:0][7:0] cache;
    // location 0 start will be 8'b0000_0001
    // location 0 done will be 8'b0000_0010
    // location 1 will be cycles in
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
                        data_plex_a[x][y] <= cache[x*SIZE+y + 2];
                        data_plex_b[x][y] <= cache[y*SIZE+x + SIZE*SIZE + 2];
                    end
            end
    end


    //The countplexes will relay the data to the systolic array
    //in the proper staggered alignment
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

    //control unit instantiation
    control #(.SIZE(SIZE)) control_inst (
        .clk(clk),
        .reset(reset),
        .cycles_in(cache[1]),
        .load_en(load_en),
        .mult_en(mult_en),
        .acc_en(acc_en),
        .done(done),
        .start(cache[0][0]),
        .memsel(memsel),
        .next(next)
    );

    //systolic array instantiation
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

    //read data address
    always @ (posedge clk)
    begin
        if(arready)
        begin
            ar_bus <= araddr;
            select <= araddr[$clog2(SIZE*SIZE)-1:0] - 1;
        end
    end
    
    //if read address is something, get accumulator data, else get status
    assign rdata = ar_bus ? d_out : {24'b0, cache[0]};

    //writing data to cache
    always @ (posedge clk)
    begin
        if(done)
            begin
                cache[0] <= 8'b0000_0010;
            end
        else if(wready)
            begin
                cache[awaddr[$clog2(SIZE*SIZE*2 + 2):0]] <= wdata;
            end
        else
            begin
                cache[awaddr[$clog2(SIZE*SIZE*2 + 2):0]] <= cache[awaddr[$clog2(SIZE*SIZE*2 + 2):0]];
            end
    end


endmodule
