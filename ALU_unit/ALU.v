`timescale 1ns/1ns

module ALU
(
    input [31:0] operand_A,
    input [31:0] operand_B_ALU,
    input [2:0] alu_control,
    output [31:0] result,
    output zero_flag,
    output negative_flag
);
    reg z_flag , n_flag;
    reg [31:0] res;   
    always @(*) begin
        case (alu_control)
                3'b001://AND
                    res = operand_A & operand_B_ALU;
                3'b010://XOR
                    res = operand_A ^ operand_B_ALU;
                3'b011://SUB
                    res = operand_A - operand_B_ALU;
                3'b100://ADD
                    res = operand_A + operand_B_ALU;
                3'b101://ORR (Bitwise OR)
                    res = operand_A | operand_B_ALU;
                3'b110://LSL (Logical Shift Left)
                    res = operand_B_ALU;
                3'b111://LSR (Logical Shift Right)
                    res = operand_B_ALU;
                3'b000:
                    res = 32'h0000;
            endcase
            n_flag = result[31];
            z_flag = result==0;
    end

    assign result = res;
    assign zero_flag = z_flag;
    assign negative_flag = n_flag;    
        
    
endmodule