`timescale 1ns/1ns

module ALU_Control (
    input [3:0] opcode,
    output [2:0] alu_control
);
    reg [2:0] alu_c;
    always @(*) begin
        alu_c = 3'b000;
        case (opcode)
            4'b0000: alu_c = 3'b001; //ADD
            4'b0001: alu_c = 3'b010; //XOR
            4'b0010: alu_c = 3'b011; //SUB
            4'b0100: alu_c = 3'b100; //ADD
            4'b1000: alu_c = 3'b101; //ORR (Bitwise OR)
            4'b1010: alu_c = 3'b110; //LSL (Logical Shift Left)
            4'b1011: alu_c = 3'b111; //LSR (Logical Shift Right) 
        endcase
    end
    assign alu_control = alu_c;
      
endmodule