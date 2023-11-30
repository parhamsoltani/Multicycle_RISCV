`timescale 1ns/1ns
`include "Execution_Unit.v"

module ALU_tb;

    parameter test_num = 10;
    reg  [31:0] A,B;
    reg  [3:0] op;
    reg [4:0] shiftAmount;
    wire [31:0] res;
    wire z_flag , n_flag;
    integer i = 0;
    Execution_Unit uut(
        .operand_A(A),.operand_B(B),
        .opcode(op),.shift_amount(shiftAmount),
        .result(res),
        .zero_flag(z_flag),
        .negative_flag(n_flag)
    );

    initial begin
        $dumpfile("ALU.vcd");
        $dumpvars(0,ALU_tb);
        for (i = 0;i<test_num;i=i+1) begin
            op=$random;
            A  =$random;
            B  =$random;
            shiftAmount =$random;

            #1;
        end

    end

    
endmodule
