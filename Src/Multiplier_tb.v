`timescale 1ns/1ns
`include "Multiplier.v"

module Multiplier_tb;

    parameter test_num = 10;
    reg [31:0] oper_1;
    reg [31:0] oper_2;
    reg [7:0] oper_3;
    reg [7:0] oper_4;
    reg en = 1;
    integer i = 0;
    Multiplier uut(
        .operand_1(oper_1),.operand_2(oper_2),.enable(en)
    );

    initial begin
        $dumpfile("Multiplier.vcd");
        $dumpvars(0,Multiplier_tb);
        for (i = 0;i<test_num;i=i+1) begin
            oper_3  =$random;
            oper_4  =$random;
            oper_1 = oper_3;
            oper_2 = oper_4;
            #1;
        end

    end

    
endmodule
