`timescale 1us/100ns

module decode_register_select(
                              output [4:0] a0,           // Register identifiers for computation
                              output [4:0] a1, 
                              output [4:0] a2, 
                              output [4:0] a2_hazard,    // Register identifier going to hazard controller
                              output [31:0] imm_to_reg,  // Immediate value going to register file
                              output [31:0] imm_to_addr, // Immediate value going to address bus
                              output [9:0] func,         // Function value for ALU control
                              output en_jmp,             // Enables jumps
                              output en_uncond_jmp,      // Signals unconditional jump
                              output en_rel_reg_jmp,     // Signals relative from register jump
                              output en_mem_wr,          // Enables write to memory
                              output en_mem_re,          // Enables read to memory
                              output [2:0] ld_code,      // Load code for write-back stage
                              output [31:0] alu_data1,   // 1st argument for ALU
                              output [31:0] alu_data2,   // 2nd argument for ALU
                              output [31:0] data_to_mem, // Data going to memory
                              output en_reg_wr,          // Enables write to memory
                              input [31:0] instr,        // Instruction
                              input [31:0] d0,           // 1st piece of data from register file
                              input [31:0] d1,           // 2nd piece of data from register file
                              input stall,               // Signal for stalling pipeline
                              input squash,              // Signal to squash instruction
                              input clk,                 // Clock
                              input rst);                // Reset

    // Enables immediates for computation
    wire en_imm;
    wire input_en_jmp;
    wire input_en_uncond_jmp; 
    wire input_en_rel_reg_jmp;
    wire [9:0] input_func;
    reg [31:0] alu_input_data2;
    wire [31:0] input_imm;
    wire [2:0] input_ld_code;
    wire [4:0] input_a2;

    wire input_en_reg_wr;
    wire en_reg_wr_conn_latch1;
    wire en_reg_wr_conn_latch2;
    pipeline_latch en_reg_wr_latch1 (.q(en_reg_wr_conn_latch1), .d(~squash & input_en_reg_wr), .stall(stall), .clk(clk), .rst(rst));
    pipeline_latch en_reg_wr_latch2 (.q(en_reg_wr_conn_latch2), .d(en_reg_wr_conn_latch1), .stall(stall), .clk(clk), .rst(rst));
    pipeline_latch en_reg_wr_latch3 (.q(en_reg_wr), .d(en_reg_wr_conn_latch2), .stall(stall), .clk(clk), .rst(rst));

    pipeline_latch en_jmp_latch (.q(en_jmp), .d(~squash & input_en_jmp), .stall(stall), .clk(clk), .rst(rst));

    pipeline_latch en_uncond_jmp_latch (.q(en_uncond_jmp), .d(~squash & input_en_uncond_jmp), .stall(stall), .clk(clk), .rst(rst));
    
    pipeline_latch en_rel_reg_jmp_latch (.q(en_rel_reg_jmp), .d(~squash &input_en_rel_reg_jmp), .stall(stall), .clk(clk), .rst(rst));

    // Function code for ALU latch
    pipeline_latch function_code_latch [9:0] (.q(func), .d({10{~squash}} & input_func), .stall(stall), .clk(clk), .rst(rst));

    // Data for ALU computation latch
    pipeline_latch data1_latch [31:0] (.q(alu_data1), .d({32{~squash}} & d0), .stall(stall), .clk(clk), .rst(rst));
    pipeline_latch data2_latch [31:0] (.q(alu_data2), .d({32{~squash}} & alu_input_data2), .stall(stall), .clk(clk), .rst(rst));
    
    // Memory data in latch
    wire [31:0] data_to_mem_conn_latch1;
    pipeline_latch data_to_mem_latch1 [31:0] (.q(data_to_mem_conn_latch1), .d({32{~squash}} & d1), .stall(stall), .clk(clk), .rst(rst));
    pipeline_latch data_to_mem_latch2 [31:0] (.q(data_to_mem), .d(data_to_mem_conn_latch1), .stall(stall), .clk(clk), .rst(rst));

    // Immediate latch
    wire [31:0] imm_conn_latch_conn;
    pipeline_latch immediate_latch1 [31:0] (.q(imm_to_addr), .d({32{~squash}} & input_imm), .stall(stall), .clk(clk), .rst(rst));
    pipeline_latch immediate_latch2 [31:0] (.q(imm_conn_latch_conn), .d(imm_to_addr), .stall(stall), .clk(clk), .rst(rst));
    pipeline_latch immediate_latch3 [31:0] (.q(imm_to_reg), .d(imm_conn_latch_conn), .stall(stall), .clk(clk), .rst(rst));

    // Enable memory write latch
    wire input_en_mem_wr;
    wire en_mem_wr_conn_latch1;
    pipeline_latch en_mem_wr_latch1(.q(en_mem_wr_conn_latch1), .d(~squash & input_en_mem_wr), .stall(stall), .clk(clk), .rst(rst));
    pipeline_latch en_mem_wr_latch2(.q(en_mem_wr), .d(en_mem_wr_conn_latch1), .stall(stall), .clk(clk), .rst(rst));

    // Enable memory read latch
    wire input_en_mem_re;
    wire en_mem_re_conn_latch1;
    pipeline_latch en_mem_re_latch1(.q(en_mem_re_conn_latch1), .d(~squash & input_en_mem_re), .stall(stall), .clk(clk), .rst(rst));
    pipeline_latch en_mem_re_latch2(.q(en_mem_re), .d(en_mem_re_conn_latch1), .stall(stall), .clk(clk), .rst(rst));
    
    // Load Code latch
    wire [2:0] ld_code_conn_latch1;
    wire [2:0] ld_code_conn_latch2;
    pipeline_latch ld_code_latch1 [2:0] (.q(ld_code_conn_latch1), .d({3{~squash}} & input_ld_code), .stall(stall), .clk(clk), .rst(rst));
    pipeline_latch ld_code_latch2 [2:0] (.q(ld_code_conn_latch2), .d(ld_code_conn_latch1), .stall(stall), .clk(clk), .rst(rst));
    pipeline_latch ld_code_latch3 [2:0] (.q(ld_code), .d(ld_code_conn_latch2), .stall(stall), .clk(clk), .rst(rst));

    // a2 latch to tell the register file at the correct time
    wire [4:0] a2_conn_latch1;
    wire [4:0] a2_conn_latch2;
    pipeline_latch a2_latch1 [4:0] (.q(a2_conn_latch1), .d({5{~squash}} & input_a2), .stall(stall), .clk(clk), .rst(rst));
    pipeline_latch a2_latch2 [4:0] (.q(a2_conn_latch2), .d(a2_conn_latch1), .stall(stall), .clk(clk), .rst(rst));
    pipeline_latch a2_latch3 [4:0] (.q(a2), .d(a2_conn_latch2), .stall(stall), .clk(clk), .rst(rst));

    // Decode Logic
    decode_logic dec (.a0(a0), .a1(a1), .a2(input_a2), .imm(input_imm), .func(input_func), 
                      .en_jmp(input_en_jmp), .en_uncond_jmp(input_en_uncond_jmp), 
                      .en_imm(en_imm), .en_reg_wr(input_en_reg_wr), .en_mem_wr(input_en_mem_wr), .en_mem_re(input_en_mem_re),
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
