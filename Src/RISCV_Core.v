`include "Defines.v"
`include "Register_File.v"
`include "Arithmetic_Logic_Unit.v"
`include "Immediate_Generator.v"
`include "Multiplier.v"

module RISCV_Core 
#(
    parameter RESET_ADDRESS = 32'h0000_0000
)
(
    input clk,
    input reset,
    output reg trap,

    input   [31 : 0] memoryData,
    input   memoryReady,
    output  reg memoryEnable,
    output  reg memoryReadWrite,
    output  reg [31 : 0] memoryAddress
);

    ////////////////
    // Controller //
    ////////////////

    reg [4 : 0] state;
    reg [4 : 0] nextState;

    reg [6 : 0] opcode;
    reg [2 : 0] funct3;
    reg [6 : 0] funct7;

    always @(*) 
    begin
        opcode = ir[ 6 :  0];
        funct3 = ir[14 : 12];
        funct7 = ir[31 : 25];    
    end

    reg pcWrite;
    reg irWrite;
    reg memoryDataRegisterWrite;

    reg instructionOrData;
    reg [1 : 0] registerWriteSource;
    reg registerWriteEnable;
    
    reg [2 : 0] instructionType;

    reg [1 : 0] aluSrcA;
    reg [1 : 0] aluSrcB;
    reg [2 : 0] aluOperation;
    
    always @(posedge clk)
    begin
        if(reset)
            state <= `RESET;
        else
            state <= nextState;
    end

    always @(*) 
    begin
        nextState = 'bz;

        memoryReadWrite = 'bz;
        pcWrite = 'bz;
        irWrite = 'bz;

        aluOperation = 'bz;
        aluSrcA = 'bz;
        aluSrcB = 'bz;
        
        multiplierEnable = 'bz;

        registerWriteSource = 'bz;
        registerWriteEnable = 'bz;

        /*
            Some sample cases are presented here in the controller FSM.
            You may need to change and complete some of them and you will
            have to add new execution and other required states to this 
            controller for your CPU to work correctly.
        */
        
        case (state)
            `RESET :   
            begin
                nextState <= `FETCH_BEGIN;
                memoryEnable <= `DISABLE;
            end
            
            `FETCH_BEGIN :   
            begin
                memoryEnable <= `ENABLE;
                memoryReadWrite <= `READ;
                instructionOrData <= `INSTRUCTION;
                nextState <= `FETCH_WAIT;
            end

            `FETCH_WAIT :
            begin
                memoryEnable <= `ENABLE;
                memoryReadWrite <= `READ;

                if(memoryReady)begin
                    irWrite <= `ENABLE;   
                    nextState <= `FETCH_DONE;   
                end
                
                else begin
                 nextState <= `FETCH_WAIT;
                
                end
                

            end

            `FETCH_DONE :
            begin

                memoryEnable <= `DISABLE;
                aluSrcA <= `PC;
                aluSrcB <= `FOUR;
                aluOperation <= `ALU_ADD;
                pcWrite <= `ENABLE;
                nextState <= `DECODE;
            
            end
            
            `DECODE :
            begin
                if (opcode == `SYSTEM) 
                    trap <= `ENABLE;
                
                case (opcode)
                 `OP:
                    instructionType <= `R_TYPE;

                `OP_IMM:
                    instructionType <= `I_TYPE;

                 `BRANCH:
                    instructionType <= `B_TYPE;

                 `SYSTEM:
                     instructionType <= `I_TYPE;

                `JAL:
                    instructionType <= `J_TYPE;         
                
                `JALR:
                    instructionType <= `I_TYPE;

                `STORE:
                    instructionType <= `S_TYPE;

                `LOAD:
                    instructionType <= `I_TYPE;

                 default: 
                     instructionType <= 3'bz;
            
                endcase

            nextState <= `EXECUTE;
            end

             `EXECUTE :
            begin
                case(opcode)
                    `OP:
                     begin 
                        aluSrcA <= `A;
                        aluSrcB <= `B;
                         
                        case({funct7,funct3})
                             {`ADD,`ADDSUB}:
                             begin
                                aluOperation <= `ALU_ADD;
                                registerWriteSource <= `ALU;
                                registerWriteEnable <= `ENABLE;
                             end
                            {`MULDIV , `MUL} :
                            begin
                                multiplierEnable <= `ENABLE;
                                registerWriteSource <= `MULTIPLIER;
                                registerWriteEnable <= `ENABLE;
                            end
                        endcase               
                        
                        nextState <= `FETCH_BEGIN;
                     end

                    `OP_IMM:
                     begin
                        aluSrcA <= `A;
                        aluSrcB <= `IMMEDIATE;
                         
                         case(funct3)
                              `ADDI:
                              begin
                                   aluOperation <= `ALU_ADD;
                                   registerWriteSource <= `ALU;
                                   registerWriteEnable <= `ENABLE;
                              end

                          
                              `ANDI:
                              begin
                                  aluOperation <= `ALU_AND;
                                  registerWriteSource <= `ALU;
                                  registerWriteEnable <= `ENABLE;
                              end

                              `ORI:
                              begin
                                  aluOperation <= `ALU_OR;
                                  registerWriteSource <= `ALU;
                                  registerWriteEnable <= `ENABLE;
                              end

                              `XORI:
                               begin
                                   aluOperation <= `ALU_XOR;
                                   registerWriteSource <= `ALU;
                                   registerWriteEnable <= `ENABLE;
                               end
                               
                         endcase
                          
                         nextState <= `FETCH_BEGIN;
                     end
                    

                    `BRANCH:
                    begin
                        aluSrcA <= `A;
                        aluSrcB <= `B;

                        case(funct3)
                            /* `BEQ:
                             begin
                                ///ir[19:15]==ir[24:20]
                                if(`A==`B)begin
                                    
                                    
                                aluOperation <= `ALU_SUB;
                                registerWriteSource <= `ALU;
                                registerWriteEnable <= `ENABLE; 

                                end
                             end */
                             `BNE:
                              begin
                                ///ir[19:15]!=ir[24:20]
                               //if(`A != `B)begin
                                    
                                aluOperation <= `ALU_SUB;
                                registerWriteSource <= `ALU;
                                registerWriteEnable <= `ENABLE;
                                end  

                                  
                              
                             /* `BLTU:
                              begin
                                ///ir[19:15]<ir[24:20]
                                if(`A < `B)begin
                                aluOperation <= `ALU_SUB;
                                registerWriteSource <= `ALU;
                                registerWriteEnable <= `ENABLE;
                                    
                                end

                            
                              end
                               */
                            /*  `BGEU:
                              begin
                                ///ir[19:15]>ir[24:20]
                                if(`A >`B)begin
                                                                    aluOperation <= `ALU_SUB;
                                registerWriteSource <= `ALU;
                                registerWriteEnable <= `ENABLE;
                                    
                                end   

                                 
                              end
                              */
                            `BGE:
                              begin
                                //$signed(ir[19:15])>$signed(ir[24:20])
                              if($signed(`A)>$signed(`B))begin
                                
                                aluOperation <= `ALU_SUB;
                                //registerWriteSource <= `ALU;
                                //registerWriteEnable <= `ENABLE;
                              
                              end     
                              end 
                              
                             /* `BLT:
                              begin
                                //$signed(ir[19:15])<$signed(ir[24:20])
                                if($signed(`A)<$signed(`B))begin
                                                                    aluOperation <= `ALU_SUB;
                                registerWriteSource <= `ALU;
                                registerWriteEnable <= `ENABLE;
                                
                                end*/

                              
                        endcase

                            nextState <= `EXECUTE_BRANCH;
                    end
                endcase
            end

            
              `EXECUTE_BRANCH :
             begin
                case (funct3)
                `BNE: 
                begin
                    if(!aluZeroRegister)begin
                        aluSrcA <=`PC;
                        aluSrcB <=`IMMEDIATE;
                        aluOperation <= `ALU_ADD;
                        nextState <= `TAKE_BRANCH;
                    end else begin

                        nextState <= `FETCH_BEGIN;    
                    end
                end
            endcase
         end
            


            `TAKE_BRANCH:
            begin
                aluSrcA <=`ALU_RESULT;
                aluSrcB <=`FOUR;
                aluOperation <= `ALU_SUB;
                pcWrite <= `ENABLE;

                nextState <=`FETCH_BEGIN;
            end
        endcase        
    end

    //////////////
    // Datapath //
    //////////////

    // ------------------------ //
    // Program Counter Register //
    // ------------------------ //
    reg [31 : 0] pc;
    
    always @(posedge clk)
    begin
        if (reset)
            pc <= RESET_ADDRESS;
        else if (pcWrite)
            pc <= aluResult; 
    end

    // -------------------- //
    // Instruction Register //
    // -------------------- //
    reg [31: 0] ir;
    always @(posedge clk) 
    begin
        if (reset)
            ir <= 'bz;
        if (irWrite)
            ir <= memoryData;
    end

    // -------------------- //
    // Memory Data Register //
    // -------------------- //
    reg [31 : 0] memoryDataRegister;
    always @(posedge clk) 
    begin
        if (memoryDataRegisterWrite)
            memoryDataRegister <= memoryData;    
    end

    // ------------- //
    // Register File //
    // ------------- //
    wire [31 : 0] readData1;
    wire [31 : 0] readData2;
    reg  [31 : 0] writeData;

    always @(*) 
    begin
        case (registerWriteSource)
            `MEMORY     :   writeData <= memoryDataRegister;
            `ALU        :   writeData <= aluResult;
            `MULTIPLIER :   writeData <= multiplierResult;
            default     :   writeData <= 'bz;
        endcase    
    end

    Register_File 
    #(
        .WIDTH(32),
        .DEPTH(5)
    )
    register_file
    (
        .clk(clk),
        .reset(reset),

        .read_enable_1(1'b1),
        .read_enable_2(1'b1),
        .write_enable(registerWriteEnable),

        .read_index_1(ir[19 : 15]),
        .read_index_2(ir[24 : 20]),
        .write_index(ir[11 : 7]),

        .write_data(writeData),

        .read_data_1(readData1),
        .read_data_2(readData2)
    );

    // --------------- //
    // A & B Registers //
    // --------------- //
    reg [31 : 0] A;
    reg [31 : 0] B;

    always @(posedge clk) 
    begin
        A <= readData1;
        B <= readData2;    
    end

    // ------------------- //
    // Immediate Generator //
    // ------------------- //
    wire [31 : 0] immediate;

    Immediate_Generator immediate_generator
    (
        .instruction(ir),
        .instruction_type(instructionType),
        .immediate(immediate)
    );
    
    // --------------------- //
    // Arithmetic Logic Unit //
    // --------------------- //
    reg  [31 : 0] aluOperand1;
    reg  [31 : 0] aluOperand2;
    wire [31 : 0] aluResult;
    wire aluZero;

    always @(*) 
    begin
        case (aluSrcA)
            `PC :           aluOperand1 <= pc;
            `A  :           aluOperand1 <= A; 
            `ALU_RESULT :   aluOperand1 <= aluResultRegister;
            default: aluOperand1 <= 'bz;
        endcase

        case (aluSrcB)
            `B          : aluOperand2 <= B;
            `FOUR       : aluOperand2 <= 32'd4; 
            `IMMEDIATE  : aluOperand2 <= immediate;
            default: aluOperand2 <= 'bz;
        endcase
    end

    Arithmetic_Logic_Unit arithmetic_logic_unit
    (
        .operation(aluOperation),
        .operand_1(aluOperand1),
        .operand_2(aluOperand2),
        .result(aluResult),
        .zero(aluZero)
    );

    reg [31 : 0] aluResultRegister;
    reg aluZeroRegister;

    always @(posedge clk) 
    begin
        aluResultRegister <= aluResult;    
        aluZeroRegister <= aluZero;
    end

    // ----------------------- //
    // Memory Address Register //
    // ----------------------- //   
    always @(*) 
    begin
        case (instructionOrData)
            `INSTRUCTION    : memoryAddress <= pc;
            `MEMORY         : memoryAddress <= aluResult; 
            default         : memoryAddress <= 'bz;
        endcase
    end

    // --------------- //
    // Multiplier Unit //
    // --------------- //  
    reg multiplierEnable;
    wire [31 : 0] multiplierResult;
    reg [31 : 0] multiplierResultRegister;

    always @(posedge clk) 
    begin
        multiplierResultRegister <= multiplierResult;    
    end

    Multiplier multiplier
    (
        .enable(multiplierEnable),
        .operand_1(A),
        .operand_2(B),
        .product(multiplierResult)
    );
endmodule
