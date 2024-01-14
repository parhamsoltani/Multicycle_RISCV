`include "Arithmetic_Logic_Unit.v"

module Arithmetic_Logic_Unit_tb;

    integer test_num = 5;
    integer i = 0;
    reg [31:0] operand_1;
    reg [31:0] operand_2;
    reg [2:0] op;
    
    Arithmetic_Logic_Unit uut(
        .operand_1(operand_1),.operand_2(operand_2),.operation(op)
    );

    initial begin
        $dumpfile("Arithmetic_Logic_Unit.vcd");
        $dumpvars(0,Arithmetic_Logic_Unit_tb);
        for (i = 0;i<=test_num;i=i+1) begin
            op = i;
            operand_1 = $random;
            operand_2 = $random;
            #1;
        end

end
    
endmodule


