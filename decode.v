`timescale 1us/100ns

`include "decode_logic.v"
`include "latch.v"

module decode_register_select(a0, a1, a2, a2_hazard, imm, func, en_jmp, en_uncond_jmp, en_rel_reg_jmp,
                              en_mem_wr, ld_code, alu_data1, alu_data2, data_to_mem, en_reg_wr,
                              instr, d0, d1, stall, squash, clk, rst);
    
    // Register identifiers for computation
    output wire [4:0] a0;
    output wire [4:0] a1;
    output wire [4:0] a2;
    output wire [4:0] a2_hazard;
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
    output wire en_reg_wr;

    // From fetch stage, the fetched instruction
    input wire [31:0] instr;
    input wire [31:0] d0;
    input wire [31:0] d1;
    input wire stall;
    input wire squash;
    input wire clk, rst;

    // Enables immediates for computation
    wire en_imm;
    wire input_en_reg_wr;
    wire input_en_jmp;
    wire input_en_uncond_jmp; 
    wire input_en_rel_reg_jmp;
    wire [9:0] input_func;
    reg [31:0] alu_input_data2;
    wire [31:0] input_imm;
    wire input_en_mem_wr;
    wire [2:0] input_ld_code;
    wire [4:0] input_a2;

    latch en_reg_wr_latch1 (.q(en_reg_wr), .d(~squash & input_en_reg_wr), .stall(stall), .clk(clk), .rst(rst));

    latch en_jmp_latch (.q(en_jmp), .d(~squash & input_en_jmp), .stall(stall), .clk(clk), .rst(rst));

    latch en_uncond_jmp_latch (.q(en_uncond_jmp), .d(~squash & input_en_uncond_jmp), .stall(stall), .clk(clk), .rst(rst));
    
    latch en_rel_reg_jmp_latch (.q(en_rel_reg_jmp), .d(~squash &input_en_rel_reg_jmp), .stall(stall), .clk(clk), .rst(rst));

    // Function code for ALU latch
    latch function_code_latch [9:0] (.q(func), .d({10{~squash}} & input_func), .stall(stall), .clk(clk), .rst(rst));

    // Data for ALU computation latch
    latch data1_latch [31:0] (.q(alu_data1), .d({32{~squash}} & d0), .stall(stall), .clk(clk), .rst(rst));
    latch data2_latch [31:0] (.q(alu_data2), .d({32{~squash}} & alu_input_data2), .stall(stall), .clk(clk), .rst(rst));
    
    // Memory data in latch
    latch data_to_mem_latch [31:0] (.q(data_to_mem), .d({32{~squash}} & d1), .stall(stall), .clk(clk), .rst(rst));

    // Immediate latch
    latch immediate_latch [31:0] (.q(imm), .d({32{~squash}} & input_imm), .stall(stall), .clk(clk), .rst(rst));

    // Enable memory write latch
    latch en_mem_wr_latch(.q(en_mem_wr), .d(~squash & input_en_mem_wr), .stall(stall), .clk(clk), .rst(rst));
    
    // Load Code latch
    latch ld_code_latch [2:0] (.q(ld_code), .d({3{~squash}} & input_ld_code), .stall(stall), .clk(clk), .rst(rst));

    // a2 latch to tell the register file at the correct time
    latch a2_latch1 [4:0] (.q(a2), .d({5{~squash}} & input_a2), .stall(stall), .clk(clk), .rst(rst));

    // Decode Logic
    decode_logic dec (.a0(a0), .a1(a1), .a2(input_a2), .imm(input_imm), .func(input_func), 
                      .en_jmp(input_en_jmp), .en_uncond_jmp(input_en_uncond_jmp), 
                      .en_imm(en_imm), .en_reg_wr(input_en_reg_wr), .en_mem_wr(input_en_mem_wr), 
                      .en_rel_reg_jmp(input_en_rel_reg_jmp), .ld_code(input_ld_code), .instr(instr));

    assign a2_hazard = {5{~squash}} & input_a2;
    always @(*) begin

        // Determine which value to use for the second value in the ALU operation
        if (en_imm)
            alu_input_data2 <= input_imm;
        else
            alu_input_data2 <= d1;
    end

endmodule
