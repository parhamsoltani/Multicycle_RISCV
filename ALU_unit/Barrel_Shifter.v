`timescale 1ns/1ns

module Barrel_Shifter (
    input [0:3] opcode,
    input [4:0] shift_amount,
    input [31:0] operand_B,
    output [31:0] operand_B_BS
);
    reg [31:0] op;
    integer i = 0 ;
    always @(*) begin
        op = operand_B;
        case (opcode)
            4'b1010:
                for (i=0;i<=shift_amount-1;i=i+1) begin
                    op = op<<1;
                end
            4'b1011:
                for (i=0;i<=shift_amount-1;i=i+1) begin
                    op = op>>1;
                end 
        endcase
        
    end
    assign operand_B_BS = op;
    
endmodule