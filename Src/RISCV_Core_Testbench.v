/*
    Run and simulate the testbench from your terminal with the following commands:

    iverilog -o RISCV_Core.vvp RISCV_Core_Testbench.v
    vvp RISCV_Core.vvp
    gtkwave RISCV_Core.gtkw

*/

`timescale 1 ns / 1 ns
`include "Defines.v"
`include "RISCV_Core.v"

`ifndef FIRMWARE
    `define FIRMWARE "Firmware\\Firmware.hex"
`endif /*FIRMWARE*/

`ifndef MEMORY_ACCESS_TIME
    `define MEMORY_ACCESS_TIME  #14
`endif /*FIRMWARE*/


module RISCV_Core_Testbench;

    
    //////////////////////
    // Clock Generation //
    //////////////////////
    parameter CLK_PERIOD = 4;
    reg clk = 1'b1;
    initial begin forever #(CLK_PERIOD/2) clk = ~clk; end
    initial #(1000 * CLK_PERIOD) $finish;
    reg reset = `ENABLE;    

    wire trap;

    //////////////////////////////
    // Memory Interface Signals //
    //////////////////////////////
    wire [31 : 0] memoryData;
    reg  [31 : 0] memoryData_reg;
    assign memoryData = memoryData_reg;

    wire [31 : 0] memoryAddress;
    wire memoryReadWrite;
    wire memoryEnable;
    reg memoryReady;

    RISCV_Core 
    #(
        .RESET_ADDRESS(32'h0000_0000)
    )
    uut
    (
        .clk(clk),
        .reset(reset),
        .trap(trap),

        .memoryData(memoryData),
        .memoryReady(memoryReady),
        .memoryEnable(memoryEnable),
        .memoryReadWrite(memoryReadWrite),
        .memoryAddress(memoryAddress)
    );

    // Debug Wires for Register File
    `ifndef DISABLE_DEBUG
        wire [31 : 0] x0_zero 	= uut.register_file.Registers[0];
        wire [31 : 0] x1_ra 	= uut.register_file.Registers[1];
        wire [31 : 0] x2_sp 	= uut.register_file.Registers[2];
        wire [31 : 0] x3_gp 	= uut.register_file.Registers[3];
        wire [31 : 0] x4_tp 	= uut.register_file.Registers[4];
        wire [31 : 0] x5_t0 	= uut.register_file.Registers[5];
        wire [31 : 0] x6_t1 	= uut.register_file.Registers[6];
        wire [31 : 0] x7_t2 	= uut.register_file.Registers[7];
        wire [31 : 0] x8_s0 	= uut.register_file.Registers[8];
        wire [31 : 0] x9_s1 	= uut.register_file.Registers[9];
        wire [31 : 0] x10_a0 	= uut.register_file.Registers[10];
        wire [31 : 0] x11_a1 	= uut.register_file.Registers[11];
        wire [31 : 0] x12_a2 	= uut.register_file.Registers[12];
        wire [31 : 0] x13_a3 	= uut.register_file.Registers[13];
        wire [31 : 0] x14_a4 	= uut.register_file.Registers[14];
        wire [31 : 0] x15_a5 	= uut.register_file.Registers[15];
        wire [31 : 0] x16_a6 	= uut.register_file.Registers[16];
        wire [31 : 0] x17_a7 	= uut.register_file.Registers[17];
        wire [31 : 0] x18_s2 	= uut.register_file.Registers[18];
        wire [31 : 0] x19_s3 	= uut.register_file.Registers[19];
        wire [31 : 0] x20_s4 	= uut.register_file.Registers[20];
        wire [31 : 0] x21_s5 	= uut.register_file.Registers[21];
        wire [31 : 0] x22_s6 	= uut.register_file.Registers[22];
        wire [31 : 0] x23_s7 	= uut.register_file.Registers[23];
        wire [31 : 0] x24_s8 	= uut.register_file.Registers[24];
        wire [31 : 0] x25_s9 	= uut.register_file.Registers[25];
        wire [31 : 0] x26_s10 	= uut.register_file.Registers[26];
        wire [31 : 0] x27_s11 	= uut.register_file.Registers[27];
        wire [31 : 0] x28_t3 	= uut.register_file.Registers[28];
        wire [31 : 0] x29_t4 	= uut.register_file.Registers[29];
        wire [31 : 0] x30_t5 	= uut.register_file.Registers[30];
        wire [31 : 0] x31_t6 	= uut.register_file.Registers[31];
    `endif /*DISABLE_DEBUG*/
    
    initial 
    begin
        $dumpfile("RISCV_Core.vcd");    
        $dumpvars(0, RISCV_Core_Testbench);
        repeat (5) @(posedge clk);
        reset <= `DISABLE;
    end

    // Check trap at end of execution 
    always @(*) 
    begin
        if (trap == `ENABLE)
            reset <= `ENABLE;    
        $finish;
    end

    ////////////
    // Memory //
    ////////////

    reg [31 : 0] Memory [0 : 4 * 1024 - 1];
    initial $readmemh(`FIRMWARE, Memory);

    // Memory Interface Behaviour
    always @(*)
    begin
        if (!memoryEnable)
        begin
            memoryData_reg <= 32'bz;
            memoryReady <= `DISABLE;
        end
    end

    always @(posedge clk)
    begin
        if (memoryEnable)
        begin
            if (memoryReadWrite == `WRITE)
                Memory[memoryAddress >> 2] <= memoryData;
            if (memoryReadWrite == `READ & !memoryReady)
            begin
                `MEMORY_ACCESS_TIME
                memoryData_reg <= Memory[memoryAddress >> 2];
                memoryReady <= `ENABLE;
            end
        end
    end

    always @(posedge clk) 
    begin
        if (memoryReady)
        begin
            memoryData_reg <= 32'bz;
            memoryReady <= `DISABLE;
        end    
    end
endmodule