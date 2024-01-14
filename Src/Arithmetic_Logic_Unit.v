`include "Defines.v"

module Arithmetic_Logic_Unit
(
    input [2 : 0] operation,

    input [31 : 0] operand_1,
    input [31 : 0] operand_2,

    output reg [31 : 0] result,
    output reg zero
);

    always @(*)
    begin
        result = 'bz;
        case(operation)
            `ALU_AND: result = operand_1 & operand_2;
            `ALU_OR : result = operand_1 | operand_2; 
            `ALU_XOR: result = operand_1 ^ operand_2; 
            `ALU_ADD: result = operand_1 + operand_2; 
            `ALU_SUB: result = operand_1 - operand_2;
        endcase
    end


    always @(*) 
    begin
        if (result == 32'b0)
            zero <= `ENABLE;
        else
            zero <= `DISABLE;    
    end
endmodule