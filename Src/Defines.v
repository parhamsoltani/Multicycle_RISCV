`ifndef OPCODES
    `define LOAD        7'b00_000_11
    `define LOAD_FP     7'b00_001_11
    `define custom_0    7'b00_010_11
    `define MISC_MEM    7'b00_011_11
    `define OP_IMM      7'b00_100_11
    `define AUIPC       7'b00_101_11
    `define OP_IMM_32   7'b00_110_11

    `define STORE       7'b01_000_11
    `define STORE_FP    7'b01_001_11
    `define custom_1    7'b01_010_11
    `define AMO         7'b01_011_11
    `define OP          7'b01_100_11
    `define LUI         7'b01_101_11
    `define OP_32       7'b01_110_11

    `define MADD        7'b10_000_11
    `define MSUB        7'b10_001_11
    `define NMSUB       7'b10_010_11
    `define NMADD       7'b10_011_11
    `define OP_FP       7'b10_100_11
    `define custom_2    7'b10_110_11

    `define BRANCH      7'b11_000_11
    `define JALR        7'b11_001_11
    `define JAL         7'b11_011_11
    `define SYSTEM      7'b11_100_11
    `define custom_3    7'b11_110_11
`endif /*OPCODES*/

`ifndef INSTRUCTION_TYPES
    `define R_TYPE 0
    `define I_TYPE 1
    `define S_TYPE 2
    `define B_TYPE 3
    `define U_TYPE 4
    `define J_TYPE 5
`endif /*INSTRUCTION_TYPES*/

`ifndef I_INSTRUCTIONS
    `define ADDI    3'b000
    `define SLTI    3'b010
    `define SLTIU   3'b011
    `define XORI    3'b100
    `define ORI     3'b110
    `define ANDI    3'b111
    `define SLLI    3'b001      // Shift Left Immediate -> Logical
    `define SRI     3'b101      // Shift Right Immediate -> Logical & Arithmetic
`endif /*I_INSTRUCTIONS*/

`ifndef R_INSTRUCTIONS
    `define ADDSUB  3'b000
    `define SLL     3'b001      // Shift Left -> Logical   
    `define SLT     3'b010
    `define SLTU    3'b011    
    `define XOR     3'b100    
    `define SR      3'b101      // Shift Right -> Logical & Arithmetic   
    `define OR      3'b110    
    `define AND     3'b111

    `define ADD     7'b0000000
    `define SUB     7'b0100000
`endif /*R_INSTRUCTIONS*/

`ifndef MUL_DIV_INSTRCUTIONS
    `define MUL     3'b000
    `define MULH    3'b001
    `define MULHSU  3'b010
    `define MULHU   3'b011 

    `define DIV     3'b100
    `define DIVU    3'b101
    `define REM     3'b110
    `define REMU    3'b111

    `define MULDIV  7'b0000001
`endif /*MUL_DIV_INSTRCUTIONS*/

`ifndef BRANCH_INSTRUCTIONS
    `define BEQ  3'b000
    `define BNE  3'b001
    `define BLT  3'b100
    `define BGE  3'b101
    `define BLTU 3'b110
    `define BGEU 3'b111
`endif /*BRANCH_INSTRUCTIONS*/

`ifndef ALU_OPERATIONS
    `define ALU_ADD     3'b000
    `define ALU_SUB     3'b001
    `define ALU_AND     3'b010
    `define ALU_OR      3'b011
    `define ALU_XOR     3'b100
`endif /*ALU_OPERATIONS*/

`ifndef ALU_SRC_SELECT
    `define PC          2'b00
    `define A           2'b01
    `define ALU_RESULT  2'b10

    `define B           2'b00
    `define FOUR        2'b01
    `define IMMEDIATE   2'b10
`endif /*ALU_SRC_SELECT*/

`ifndef REGISTER_FILE_WRITE_SOURCE
    `define MEMORY      2'b00
    `define ALU         2'b01
    `define MULTIPLIER  2'b10
`endif /*REGISTER_FILE_WRITE_SOURCE*/

`ifndef CONTROL_SIGNALS
    `define INSTRUCTION     1'b0
    `define DATA            1'b1

    `define READ            1'b0
    `define WRITE           1'b1

    `define DISABLE         1'b0
    `define ENABLE          1'b1
`endif /*CONTROL_SIGNALS*/

`ifndef CONTROLLER_STATES
    `define RESET            0
    `define FETCH_BEGIN      1
    `define FETCH_WAIT       2
    `define FETCH_DONE       3
    `define DECODE           4
    `define EXECUTE          5
    `define EXECUTE_BRANCH   6
    `define TAKE_BRANCH      7
`endif /*CONTROLLER_STATES*/