`timescale 1us/100ns

`include "decode_logic"

`define BRANCH_CONTROL_LATCH_OUTPUT {en_jmp, en_uncond_jmp, en_rel_reg_jmp}
`define BRANCH_CONTROL_LATCH_INPUT {input_en_jmp, input_en_uncond_jmp, input_en_rel_reg_jmp}

module decode_register_select(a0, a1, a2, imm, func, en_jmp, en_uncond_jmp, en_branch, en_imm, en_reg_wr, en_mem_wr, ld_code, instr, stall, clk, rst);
    
    // Leaving decode stage, immediate value (if there is one)
    output wire [31:0] imm;
    // Leaving decode stage, function value (if there is one)
    output wire [9:0] func;
    // Leaving decode stage, enables if a jump can be taken
    output wire en_jmp;
    // Leaving decode stage, enables unconditional jumps
    output wire en_uncond_jmp;
    // Leaving decode stage, enables unconditional jump relative to value in a register
    output wire en_rel_reg_jmp;
    // Leaving decode stage, enables the use of immediates
    output wire en_imm;
    // Leaving decode stage, enables a write to the register
    output wire en_reg_wr;
    // Leaving decode stage, enables a write to memory
    output wire en_mem_wr;
    // Leaving decode stage, value that determines which value is put on the register write bus
    output wire [2:0] ld_code;
    // Leaving decode stage, output data from register file
    output wire [31:0] d0;
    output wire [31:0] d1;

    // From fetch stage, the fetched instruction
    input wire [31:0] instr;
    input wire clk, rst;
    input wire stall;
    
    // Register identifier for computation
    wire [4:0] a0;
    wire [4:0] a1;
    wire [4:0] a2;
    // Enables a write to the register
    wire en_reg_wr;
    // Enables immediates for computation
    wire en_imm;

    // Branch control logic latch
    wire input_en_jmp; 
    wire input_en_uncond_jmp; 
    wire input_en_rel_reg_jmp;
    latch latch1 [2:0] (.q(BRANCH_CONTROL_LOGIC_OUTPUT), .d(BRANCH_CONTROL_LOGIC_INPUT), .stall(stall), .clk(clk), .rst(rst));

    // Function code for ALU latch
    wire input_func;
    latch function_code_latch (.q(func), .d(input_func), .stall(stall), .clk(clk), .rst(rst));

    // Data for ALU computation latch
    wire input_data1;
    wire input_data2;
    latch d0_latch (.q(data1), .d(input_data1), .stall(stall), .clk(clk), .rst(rst));
    latch d1_latch (.q(data2), .d(input_data2), .stall(stall), .clk(clk), .rst(rst));
    
    // Memory data in latch
    latch data_in_latch(.q(data_in), .d(d1), .stall(stall), .clk(clk), .rst(rst));

    // Immediate latch
    wire input_imm;
    latch immediate_latch(.q(imm), .d(input_imm), .stall(stall), .clk(clk), .rst(rst));

    // Enable memory write latch
    wire input_en_mem_wr;
    latch en_mem_wr_latch(.q(en_mem_wr), .d(input_en_mem_wr), .stall(stall), .clk(clk), .rst(rst));

    // Decode Logic
    decode_logic dec (.a0(a0), .a1(a1), 
                  .a2(a2), .imm(input_imm), .func(input_func), 
                  .en_jmp(input_en_jmp), .en_uncond_jmp(input_en_uncond_jmp), 
                  .en_imm(en_imm), .en_reg_wr(en_reg_wr), .en_mem_wr(input_en_mem_wr), 
                  .en_rel_reg_jmp(input_en_rel_reg_jmp), .ld_code(ld_code), .instr(instr));
    // Register File
    wire d1;
    reg_file regs (.a0(a0), .a1(a1), .a2(a2), .din(reg_out_bits), .reg_wr(en_reg_wr & data_hazard), .d0(input_data1), .d1(d1), .clk(clk), .rst(rst));

    always @(*) begin

        // Determine which value to use for the second value in the ALU operation
        if (en_imm)
            input_data2 <= input_imm;
        else
            input_data2 <= d1;

endmodule
