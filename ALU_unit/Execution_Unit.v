`timescale 1ns/1ns
`include "ALU_Control.v"
`include "Barrel_Shifter.v"
`include "ALU.v"

module Execution_Unit (
    input [31:0] operand_A,
    input [31:0] operand_B,
    input [3:0] opcode,
    input [4:0] shift_amount,
    output [31:0] result,
    output zero_flag,
    output negative_flag
);

ALU_Control AC (
    .opcode(opcode)
);
Barrel_Shifter BS(
      .opcode(opcode),.shift_amount(shift_amount),
      .operand_B(operand_B)
);
ALU alu(
    .operand_B_ALU(BS.operand_B_BS),.operand_A(operand_A),
    .alu_control(AC.alu_control)
);

    assign result = alu.result;
    assign zero_flag = alu.zero_flag;
    assign negative_flag = alu.negative_flag;

endmodule