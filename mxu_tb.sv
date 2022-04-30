`timescale 1ns / 10ps


module mxu_tb;

    parameter SIZE = 4;

    logic clk, reset;

    logic wready, rready, arready;
    logic [7:0] wdata;
    logic [31:0] awaddr;
    logic [31:0] rdata;
    logic [31:0] araddr;

    mxu #(.SIZE(SIZE)) DUT (
        .clk(clk),
        .reset(reset),
        .wdata(wdata),
        .awaddr(awaddr),
        .wready(wready),
        .rdata(rdata),
        .araddr(araddr),
        .arready(arready),
        .rready(rready)
    );


    integer i, j, k;

    logic [3:0][3:0][7:0] matrix_a = '{'{5, 2, 6, 1},'{0, 6, 2, 0},'{3, 8, 1, 4},'{1, 8, 5, 6}};
    logic [3:0][3:0][7:0] matrix_b = '{'{7, 5, 8, 0},'{1, 8, 2, 6},'{9, 4, 3, 8},'{5, 3, 7, 9}};


    initial
    begin

        //setting signals low
        clk = 0;
        reset = 1;
        araddr = 0;
        rready = 0;
        wready = 0;
        awaddr = 0;
        arready = 0;

        //reset system
        #10;
        clk = 1;
        #10
        clk = 0;
        reset = 0;

        //loading data to A

        for(i = 0; i < SIZE; i++)
            begin
                for(j = 0; j < SIZE; j++)
                    begin
                        #10;
                        clk = 1;
                        awaddr = 2 + j + i*SIZE;
                        #10;
                        clk = 0;
                        #10;
                        clk = 1;
                        #10;
                        clk = 0;
                        wdata = matrix_a[SIZE-i-1][SIZE-j-1];
                        wready = 1;
                        #10;
                        clk = 1;
                        #10;
                        clk = 0;
                        wready = 0;
                        #10;
                        clk = 1;
                        #10;
                        clk = 0;
                        #10;
                    end
            end

            //loading data to B

        for(i = 0; i < SIZE; i++)
            begin
                for(j = 0; j < SIZE; j++)
                    begin
                        #10;
                        clk = 1;
                        awaddr = 2 + SIZE*SIZE + j + i*SIZE;
                        #10;
                        clk = 0;
                        #10;
                        clk = 1;
                        #10;
                        clk = 0;
                        wdata = matrix_b[SIZE-i-1][SIZE-j-1];
                        wready = 1;
                        #10;
                        clk = 1;
                        #10;
                        clk = 0;
                        wready = 0;
                        #10;
                        clk = 1;
                        #10;
                        clk = 0;
                        #10;
                    end
            end

            //setting how many cycles
        #10;
        clk = 0;
        awaddr = 1;
        #10;
        clk = 1;
        #10;
        clk = 0;
        wdata = 20;
        wready = 1;
        #10;
        clk = 1;
        #10;
        clk = 0;
        wready = 0;
        awaddr = 0;
        #10;
        clk = 1;
        #10;
        clk = 0;
        #10;

        //start matrix multiplication    
        #10;
        clk = 0;
        wdata = 8'b0000_0001;
        wready = 1;
        #10;
        clk = 1;
        #10;
        clk = 0;
        wready = 0;
        #10;
        for(k = 0; k < 20*3 + 5; k++)
            begin
                #10;
                clk = 1;
                #10;
                clk = 0;
            end
        

            //read from accumulator
        for(k = 0; k < SIZE*SIZE; k++)
            begin
                #10;
                clk = 1;
                #10;
                clk = 0;
                araddr = 1 + k;
                arready = 1;
                #10;
                clk = 1;
                #10;
                clk = 0;
                arready = 0;
                #10;
                clk = 1;
                #10;
                clk = 0;
                #10;
                clk = 1;
                #10;
                clk = 0;
            end


        $finish;


    end


endmodule
