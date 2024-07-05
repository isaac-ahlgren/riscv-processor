`timescale 1us/100ns

`include "decode_logic.v"

`define BRANCH_CONTROL_LATCH_OUTPUT {en_jmp, en_uncond_jmp, en_rel_reg_jmp}
`define BRANCH_CONTROL_LATCH_INPUT {input_en_jmp, input_en_uncond_jmp, input_en_rel_reg_jmp}

module decode_register_select(imm, func, en_jmp, en_uncond_jmp, en_rel_reg_jmp,
                              en_mem_wr, ld_code, alu_data1, alu_data2, data_to_mem, 
                              instr, data_to_reg, stall, control_hazard, clk, rst);
    
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
    // Leaving decode stage, enables a write to memory
    output wire en_mem_wr;
    // Leaving decode stage, value that determines which value is put on the register write bus
    output wire [2:0] ld_code;
    // Leaving decode stage, output data from register file
    output wire [31:0] alu_data1;
    output wire [31:0] alu_data2;
    // Leaving decode stage, data that is going to be written to memory
    output wire [31:0] data_to_mem;

    // From fetch stage, the fetched instruction
    input wire [31:0] instr;
    input wire [31:0] data_to_reg;
    input wire stall;
    input wire control_hazard;
    input wire clk, rst;
    
    // Register identifier for computation
    wire [4:0] a0;
    wire [4:0] a1;
    wire [4:0] a2;
    // Enables a write to the register
    wire en_reg_wr;
    // Enables immediates for computation
    wire en_imm;
    wire [31:0] d1;

    // Branch control logic latch
    wire input_en_jmp; 
    wire input_en_uncond_jmp; 
    wire input_en_rel_reg_jmp;
    latch branch_control_logic_latch [2:0] (.q(BRANCH_CONTROL_LOGIC_OUTPUT), .d(BRANCH_CONTROL_LOGIC_INPUT), .stall(stall), .clk(clk), .rst(rst));

    // Function code for ALU latch
    wire input_func;
    latch function_code_latch (.q(func), .d(input_func), .stall(stall), .clk(clk), .rst(rst));

    // Data for ALU computation latch
    wire [31:0] alu_input_data1;
    reg [31:0] alu_input_data2;
    latch data1_latch [31:0] (.q(data1), .d(input_data1), .stall(stall), .clk(clk), .rst(rst));
    latch data2_latch [31:0] (.q(data2), .d(input_data2), .stall(stall), .clk(clk), .rst(rst));
    
    // Memory data in latch
    latch data_to_mem_latch [31:0] (.q(data_to_mem), .d(d1), .stall(stall), .clk(clk), .rst(rst));

    // Immediate latch
    wire input_imm;
    latch immediate_latch(.q(imm), .d(input_imm), .stall(stall), .clk(clk), .rst(rst));

    // Enable memory write latch
    wire input_en_mem_wr;
    latch en_mem_wr_latch(.q(en_mem_wr), .d(input_en_mem_wr), .stall(stall), .clk(clk), .rst(rst));

    // Decode Logic
    decode_logic dec (.a0(a0), .a1(a1), .a2(a2), .imm(input_imm), .func(input_func), 
                  .en_jmp(input_en_jmp), .en_uncond_jmp(input_en_uncond_jmp), 
                  .en_imm(en_imm), .en_reg_wr(en_reg_wr), .en_mem_wr(input_en_mem_wr), 
                  .en_rel_reg_jmp(input_en_rel_reg_jmp), .ld_code(ld_code), .instr(instr));
    // Register File
    reg_file regs (.a0(a0), .a1(a1), .a2(a2), .din(data_to_reg), .reg_wr(en_reg_wr & control_hazard), .d0(alu_input_data1), .d1(d1), .clk(clk), .rst(rst));

    always @(*) begin

        // Determine which value to use for the second value in the ALU operation
        if (en_imm)
            alu_input_data2 <= input_imm;
        else
            alu_input_data2 <= d1;
    end

endmodule
