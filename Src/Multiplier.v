`include "Defines.v"

module Multiplier
(
    input enable,

    input [31 : 0] operand_1,
    input [31 : 0] operand_2,
    output reg [31 : 0] product
);

    reg [3:0] neg;
    reg [3:0] bit_inverted_1;
    reg [3:0] bit_inverted_2;
    reg [15:0] partial_product_0;
    reg [15:0] partial_product_1;
    reg [15:0] partial_product_2;
    reg [15:0] partial_product_3;
    reg [7:0]product_bits;
    reg [2:0]carry_bits;
    reg [7:0] operand_1_complement;
    reg adjacent_jump;
    reg adjacent_jump_1;
    reg is_negative;
    integer i ;
    integer j ;
    reg [15:0]result;
    reg [7:0]carry_status;
    reg next_adjacent_jump;
    reg next_adjacent_jump_1;
    reg is_negative_result;

    always @(*)
    begin

        if(enable==1) begin
            i = 0;
            j = 0;
            carry_status = 8'b0;
            bit_inverted_1[0] = ~(operand_2[2*0]^0);
            bit_inverted_2[0]= ~(( operand_2[2*0+1] & ~operand_2[2*0] & (~0)  ) | ( (~operand_2[2*0+1]) & (operand_2[2*0]) & 0 ) );
            neg[0] = ((~(0))|(~(operand_2[2*0])))&(operand_2[2*0+1]);
            carry_bits[0] = neg[0] & ( ~operand_1[0] | bit_inverted_1[0]);
                
            bit_inverted_1[1] = ~(operand_2[2*1]^operand_2[2*1-1]);
            bit_inverted_2[1]= ~(( operand_2[2*1+1] & ~operand_2[2*1] & (~operand_2[2*1-1])  ) | ( (~operand_2[2*1+1]) & (operand_2[2*1]) & operand_2[2*1-1] ) );
            neg[1] = ((~(operand_2[2*1-1]))|(~(operand_2[2*1])))&(operand_2[2*1+1]);
            carry_bits[1] = neg[1] & ( ~operand_1[0] | bit_inverted_1[1]);

            bit_inverted_1[2] = ~(operand_2[2*2]^operand_2[2*2-1]);
            bit_inverted_2[2]= ~(( operand_2[2*2+1] & ~operand_2[2*2] & (~operand_2[2*2-1])  ) | ( (~operand_2[2*2+1]) & (operand_2[2*2]) & operand_2[2*2-1] ) );
            neg[2] = ((~(operand_2[2*2-1]))|(~(operand_2[2*2])))&(operand_2[2*2+1]);
            carry_bits[2] = neg[2] & ( ~operand_1[0] | bit_inverted_1[2]);


            bit_inverted_1[3] = ~(operand_2[2*3]^operand_2[2*3-1]);
            bit_inverted_2[3]= ~(( operand_2[2*3+1] & ~operand_2[2*3] & (~operand_2[2*3-1])  ) | ( (~operand_2[2*3+1]) & (operand_2[2*3]) & operand_2[2*3-1] ) );
            neg[3] = ((~(operand_2[2*3-1]))|(~(operand_2[2*3])))&(operand_2[2*3+1]);

            for(i=0;i<=2;++i) begin
                
                for(j=0;j<=7;++j)begin 
                    if (j==0) begin
                        adjacent_jump = operand_1[j];
                        adjacent_jump_1 = 0;
                    end else begin
                        adjacent_jump = operand_1[j];
                        adjacent_jump_1 = operand_1[j-1];
                    end
                    next_adjacent_jump_1 = ~((adjacent_jump_1)^(neg[i]));
                    next_adjacent_jump = ~((adjacent_jump)^(neg[i]));
                    product_bits[j] = ~( (  (bit_inverted_2[i])|( next_adjacent_jump_1  )  )&(   (bit_inverted_1[i])|( next_adjacent_jump )  ) );
                    if(j==7) begin
                        is_negative_result = ~next_adjacent_jump & (~bit_inverted_1[i] | ~bit_inverted_2[i]);
                    end
                end

                product_bits[0] = ~(bit_inverted_1[i]) & operand_1[0];
                

                case (i) //[i][15:0]
                    0 : partial_product_0 = {5'b0, ~is_negative_result ,is_negative_result ,is_negative_result , product_bits[7] ,product_bits[6],product_bits[5],product_bits[4],product_bits[3],product_bits[2],product_bits[1],product_bits[0] };  
                    1 : partial_product_1 = {4'b0,1'b1 ,~is_negative_result , product_bits[7] ,product_bits[6],product_bits[5],product_bits[4],product_bits[3],product_bits[2],product_bits[1],product_bits[0] , carry_bits[i-1],1'b0 };
                    2 : partial_product_2 = {2'b0 ,  1'b1 ,~is_negative_result , product_bits[7] ,product_bits[6],product_bits[5],product_bits[4],product_bits[3],product_bits[2],product_bits[1],product_bits[0] , carry_bits[i-1],1'b0,1'b0,1'b0 };
                endcase
            end
                for(i=0;i<=3;++i) begin
                    if(operand_1[2*i]==1'b1)begin
                        carry_status[2*i] = 1;
                        carry_status[2*i+1] = 1;
                    end else begin
                        if(operand_1[2*i]==1'b1) begin
                            carry_status[2*i] = 0;
                            carry_status[2*i+1] = 1;
                        end else begin
                            carry_status[2*i] = 0;
                            carry_status[2*i+1] = 0;
                        end
                    end
                end
                for(i=0;i<=1;++i) begin
                    if(carry_status[4*i+1]==1)begin
                        carry_status[4*i+2] =1;
                        carry_status[4*i+2] =1;
                    end
                end
                if(carry_status[3]==1) begin
                    carry_status[4]=1;
                    carry_status[5]=1;
                    carry_status[6]=1;
                    carry_status[7]=1;
                end
                is_negative = 0;
                for (i = 0; i<=7;++i ) begin
                    if(is_negative==1'b1) begin
                        operand_1_complement[i] = ~operand_1[i];
                    end else begin
                        operand_1_complement[i] = operand_1[i];
                    end
                    if(carry_status[i]==1'b1) begin
                        is_negative = 1;
                    end
                end

            
            if(neg[3]==1'b1) begin
                neg[3]=0;
                for(j=0;j<=7;++j)begin 
                    if (j==0) begin
                        adjacent_jump = operand_1_complement[j];
                        adjacent_jump_1 = 0;
                    end else begin
                        adjacent_jump = operand_1_complement[j];
                        adjacent_jump_1 = operand_1_complement[j-1];
                    end
                    product_bits[j] = ~( (  (bit_inverted_2[3])|(~((adjacent_jump_1)^(neg[3])))  )&(   (bit_inverted_1[3])|(~((adjacent_jump)^(neg[3])))  ) );
                end

                
                partial_product_3 = {  1'b1 ,~product_bits[7] , product_bits[7] ,product_bits[6],product_bits[5],product_bits[4],product_bits[3],product_bits[2],product_bits[1],product_bits[0] , carry_bits[2],1'b0,1'b0,1'b0 ,1'b0,1'b0};          
            end else begin
                for(j=0;j<=7;++j)begin 
                    if (j==0) begin
                        adjacent_jump = operand_1[j];
                        adjacent_jump_1 = 0;
                    end else begin
                        adjacent_jump = operand_1[j];
                        adjacent_jump_1 = operand_1[j-1];
                    end
                    product_bits[j] = ~( (  (bit_inverted_2[3])|(~((adjacent_jump_1)^(neg[3])))  )&(   (bit_inverted_1[3])|(~((adjacent_jump)^(neg[3])))  ) );
                end

                product_bits[0] = ~(bit_inverted_1[3]) & operand_1[0];
                partial_product_3 = {  1'b1 ,~product_bits[7] , product_bits[7] ,product_bits[6],product_bits[5],product_bits[4],product_bits[3],product_bits[2],product_bits[1],product_bits[0] , carry_bits[2],1'b0,1'b0,1'b0 ,1'b0,1'b0};                 
            end
            result = partial_product_0 + partial_product_1 + partial_product_2 + partial_product_3;
            product = {   {16{result[15]}}  ,result};
            end
    end 
    

endmodule