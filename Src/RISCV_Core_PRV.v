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

    inout   [31 : 0] memoryData,
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
                if (memoryReady)
                    nextState <= `FETCH_DONE;
            end

            `FETCH_DONE :
            begin
                irWrite <= `ENABLE;
                pcWrite <= `ENABLE;
                aluSrcA <= `PC;
                aluSrcB <= `FOUR;
                aluOperation <= `ADD;
                nextState <= `DECODE;
            end
            
            `DECODE :
            begin
                if (opcode == `SYSTEM) 
                    trap <= `ENABLE;    
                case (opcode)
                    `OP         : instructionType <= `R_TYPE;
                    `OP_IMM     : instructionType <= `I_TYPE;
                    `LOAD       : instructionType <= `I_TYPE;
                    `JALR       : instructionType <= `I_TYPE;
                    `BRANCH     : instructionType <= `B_TYPE;
                    `AUIPC      : instructionType <= `U_TYPE;
                    `LUI        : instructionType <= `U_TYPE;
                    `STORE      : instructionType <= `S_TYPE;
                    `JAL        : instructionType <= `J_TYPE;
                endcase
                nextState <= `EXECUTE;
            end

            `EXECUTE :
            begin
                case (instructionType)
                    `R_TYPE     : 
                    begin
                            aluSrcA <= `A;
                            aluSrcB <= `B;

                            case(funct3)
                                `ADDSUB :
                                begin
                                    case (funct7)
                                        `ADD : aluOperation = `ALU_ADD;
                                        `SUB : aluOperation = `ALU_SUB;
                                    endcase
                                end
                                `SLL : aluOperation = `ALU_SHIFT_LEFT;
                                `SLT : aluOperation = `ALU_SLT;
                                `SLTU: aluOperation = `ALU_SLTU;
                                `XOR : aluOperation = `ALU_XOR;
                                `SR  : aluOperation = `ALU_SR;
                                `OR  : aluOperation = `ALU_OR;
                                `AND : aluOperation = `ALU_AND;

                            endcase
                            registerWriteEnable <= `ENABLE;
                            registerWriteSource <= `ALU_RESULT;
                    end 

                    `I_TYPE     :
                    begin 
                            aluSrcA <= `A;
                            aluSrcB <= `IMMEDIATE;
                            nextState <= `EXECUTE_BRANCH;
                            case (funct3)
                                `ADDI: aluOperation <= `ALU_ADD;
                                `SLTI: aluOperation <= `ALU_SUB; // Subtract for set less than
                                `SLTIU: aluOperation <= `ALU_SLTU;
                                `XORI : aluOperation = `ALU_XOR;
                                `SRI  : aluOperation = `ALU_SHIFT_RIGHT_LOGICAL;
                                `ORI  : aluOperation = `ALU_OR;
                                `ANDI : aluOperation = `ALU_AND;
                                `SLLI : aluOperation = `ALU_SHIFT_LEFT;
                            endcase
                            registerWriteEnable <= `ENABLE;
                            registerWriteSource <= `ALU_RESULT;
                    end

                    `B_TYPE     : 
                    begin
                            aluSrcA <= `A;
                            aluSrcB <= `B;
                            case (funct3)
                                `BEQ: aluOperation <= `ALU_SUB;
                                `BNE: aluOperation <= `ALU_SUB;
                                `BLT: aluOperation <= `ALU_SUB;
                                `BGE: aluOperation <= `ALU_SUB;
                                `BLTU: aluOperation <= `ALU_SUB;
                                `BGEU: aluOperation <= `ALU_SUB;
                            endcase
                            nextState <= `EXECUTE_BRANCH;
                    end

                    `U_TYPE     :
                    begin
                        // U-Type instructions (LUI and AUIPC)
                        aluSrcA <= `IMMEDIATE;
                        aluSrcB <= `ZERO; // This is a placeholder. 
                        aluOperation <= `ALU_ADD;
                        registerWriteEnable <= `ENABLE;
                        registerWriteSource <= `ALU_RESULT;
                    end


                    `S_TYPE     :
                    begin
                        // Store instructions
                        aluSrcA <= `A;
                        aluSrcB <= `IMMEDIATE;
                        aluOperation <= `ALU_ADD; // For address calculation
                        nextState <= `EXECUTE_BRANCH;
                    end


                    `J_TYPE     :
                    begin
                        // J-Type instruction (JAL)
                        aluSrcA <= `PC;
                        aluSrcB <= `IMMEDIATE;
                        aluOperation <= `ALU_ADD; // For address calculation
                        registerWriteEnable <= `ENABLE;
                        registerWriteSource <= `ALU_RESULT;
                        nextState <= `EXECUTE_BRANCH;
                    end

                    `MULDIV :
                    begin
                        case (funct3)
                            `MUL :
                            begin
                                // Multiplication
                                aluSrcA <= `A;
                                aluSrcB <= `B;
                                aluOperation = `ALU_MUL;
                                registerWriteEnable <= `ENABLE;
                                registerWriteSource <= `ALU_RESULT;
                                multiplierEnable = `ENABLE;
                            end

                            `MULH :
                            begin
                                // Multiply High (signed)
                                aluSrcA <= `A;
                                aluSrcB <= `B;
                                aluOperation = `ALU_MULH;
                                registerWriteEnable <= `ENABLE;
                                registerWriteSource <= `ALU_RESULT;
                                multiplierEnable = `ENABLE;
                            end

                            `MULHSU :
                            begin
                                // Multiply High (signed-unsigned)
                                aluSrcA <= `A;
                                aluSrcB <= `B;
                                aluOperation = `ALU_MULHSU;
                                registerWriteEnable <= `ENABLE;
                                registerWriteSource <= `ALU_RESULT;
                                multiplierEnable = `ENABLE;
                            end

                            `MULHU :
                            begin
                                // Multiply High (unsigned)
                                aluSrcA <= `A;
                                aluSrcB <= `B;
                                aluOperation = `ALU_MULHU;
                                registerWriteEnable <= `ENABLE;
                                registerWriteSource <= `ALU_RESULT;
                                multiplierEnable = `ENABLE;
                            end

                            `DIV :
                            begin
                                // Division (signed)
                                aluSrcA <= `A;
                                aluSrcB <= `B;
                                aluOperation = `ALU_DIV;
                                registerWriteEnable <= `ENABLE;
                                registerWriteSource <= `ALU_RESULT;
                            end

                            `DIVU :
                            begin
                                // Division (unsigned)
                                aluSrcA <= `A;
                                aluSrcB <= `B;
                                aluOperation = `ALU_DIVU;
                                registerWriteEnable <= `ENABLE;
                                registerWriteSource <= `ALU_RESULT;
                            end

                            `REM :
                            begin
                                // Remainder (signed)
                                aluSrcA <= `A;
                                aluSrcB <= `B;
                                aluOperation = `ALU_REM;
                                registerWriteEnable <= `ENABLE;
                                registerWriteSource <= `ALU_RESULT;
                            end

                            `REMU :
                            begin
                                // Remainder (unsigned)
                                aluSrcA <= `A;
                                aluSrcB <= `B;
                                aluOperation = `ALU_REMU;
                                registerWriteEnable <= `ENABLE;
                                registerWriteSource <= `ALU_RESULT;
                            end
                        endcase
                    end

                    // ...
                endcase
                // Update nextState based on the executed instruction
                `EXECUTE_BRANCH :
                begin
                    case (instructionType)
                        `B_TYPE :
                        begin
                            case (funct3)
                                `BEQ  : nextState = (aluZero) ? `TAKE_BRANCH : `NEXT_PC;
                                `BNE  : nextState = (aluZero) ? `NEXT_PC : `TAKE_BRANCH;
                                `BLT  : nextState = (aluZero) ? `TAKE_BRANCH : `NEXT_PC;
                                `BGE  : nextState = (aluZero) ? `NEXT_PC : `TAKE_BRANCH;
                                `BLTU : nextState = (aluZero) ? `TAKE_BRANCH : `NEXT_PC;
                                `BGEU : nextState = (aluZero) ? `NEXT_PC : `TAKE_BRANCH;
                            endcase
                        end
                        `I_TYPE :
                        begin
                            case (funct3)
                                `JALR : nextState = (aluZero) ? `TAKE_BRANCH : `NEXT_PC;
                                default: nextState = `NEXT_PC;
                            endcase
                        end

                `TAKE_BRANCH :
                begin
                    pcWrite = `ENABLE;
                    irWrite = `DISABLE;
                    memoryDataRegisterWrite = `DISABLE;
                    registerWriteEnable = `DISABLE;
                    registerWriteSource = `bz;
                    aluSrcA = `PC;
                    aluSrcB = `IMMEDIATE;
                    aluOperation = `ALU_ADD;
                    nextState = `FETCH_BEGIN;
                end
            end
            
            /* Additional States need to be declared here as follow:
            `NEW_STATE:
            begin

            end
            */
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