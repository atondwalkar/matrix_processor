`timescale 1ns / 1ps

module control(
    clk,
    reset,
    cycles_in,
    start,
    load_en,
    mult_en,
    acc_en,
    memsel,
    next,
    done
    );
    
    parameter SIZE = 16;
    
    input logic clk, reset, start;
    input logic [7:0] cycles_in;
    output logic load_en, mult_en, acc_en;
    output logic [SIZE-1:0] memsel;
    output logic done, next;
    
    logic [2:0] state;
    logic [7:0] cycles;
    logic [1:0] mac_cycles;
    
    initial
    begin
        state <= 0;
    end
    
    always @ (posedge clk)
    begin
        if(reset)
        begin
            state <= 0;
            load_en <= 0;
            mult_en <= 0;
            acc_en <= 0;
            memsel <= 0;
            cycles <= 0;
            mac_cycles <= 0;
            done <= 0;
            next <= 0;
        end
        if(state == 0)
        begin
            if(start)
            begin
                state <= 1;
            end
            else
            begin
                state <= 0;
                load_en <= 0;
                mult_en <= 0;
                acc_en <= 0;
                memsel <= 0;
                cycles <= 0;
                mac_cycles <= 0;
                done <= 0;
                next <= 0;
            end
        end
        if(state == 1)
        begin
            if(cycles != cycles_in) //how many elements to multiply in array
            begin
                case (mac_cycles) //mac unit has 3 steps
                    0   : 
                        begin
                        mac_cycles <= 1;
                        load_en <= 1;
                        mult_en <= 0;
                        acc_en <= 0;
                        next <= 0;
                        if(cycles < SIZE)
                        begin
                            memsel <= {memsel[SIZE-1:0], 1'b1}; 
                        end
                        else
                        begin
                            memsel <= {memsel[SIZE-1:0], 1'b0};
                        end
                        end
                    1   :
                        begin
                        mac_cycles <= 2;
                        load_en <= 0;
                        mult_en <= 1;
                        acc_en <= 0;
                        next <= 0;
                        end
                    2   :
                        begin
                        mac_cycles <= 0;
                        load_en <= 0;
                        mult_en <= 0;
                        acc_en <= 1;
                        cycles <= cycles + 1;
                        next <= 1;
                        end
                    default :
                        begin
                        mac_cycles <= 0;
                        load_en <= 0;
                        mult_en <= 0;
                        acc_en <= 0;
                        next <= 0;
                        end
                endcase
            end
            else
            begin
                state <= 2;
                load_en <= 0;
                mult_en <= 0;
                acc_en <= 0;
                next <= 0;
            end
        end
        if(state == 2)
        begin
            done <= 1;
            state <= 3;
        end
        if(state == 3)
        begin
            done <= 0;
            state <= 0;
        end
    
    end
    
    
endmodule
