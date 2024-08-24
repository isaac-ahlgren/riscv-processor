`timescale 1us/100ns

module decode_register_select(a0, a1, a2, a2_hazard, imm_to_reg, imm_to_addr, func, en_jmp, en_uncond_jmp, en_rel_reg_jmp,
                              en_mem_wr, en_mem_re, ld_code, alu_data1, alu_data2, data_to_mem, en_reg_wr, dmem_addr_bus_use,
                              instr, d0, d1, stall, squash, clk, rst);
    
    // Register identifiers for computation
    output wire [4:0] a0;
    output wire [4:0] a1;
    output wire [4:0] a2;
    output wire [4:0] a2_hazard;
    // Leaving decode stage, immediate values (if there is one)
    output wire [31:0] imm_to_reg;
    output wire [31:0] imm_to_addr;
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
    // Leaving decode stage, enables a read from memory
    output wire en_mem_re;
    // Leaving decode stage, value that determines which value is put on the register write bus
    output wire [2:0] ld_code;
    // Leaving decode stage, output data from register file
    output wire [31:0] alu_data1;
    output wire [31:0] alu_data2;
    // Leaving decode stage, data that is going to be written to memory
    output wire [31:0] data_to_mem;
    output wire en_reg_wr;
    output wire dmem_addr_bus_use;

    // From fetch stage, the fetched instruction
    input wire [31:0] instr;
    input wire [31:0] d0;
    input wire [31:0] d1;
    input wire stall;
    input wire squash;
    input wire clk, rst;

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
    
    wire input_dmem_addr_bus_use;
    wire dmem_addr_bus_use_conn_latch1;
    pipeline_latch dmem_addr_bus_use_latch1(.q(dmem_addr_bus_use_conn_latch1), .d(~squash & input_dmem_addr_bus_use), .stall(stall), .clk(clk), .rst(rst));
    pipeline_latch dmem_addr_bus_use_latch2(.q(dmem_addr_bus_use), .d(dmem_addr_bus_use_conn_latch1), .stall(stall), .clk(clk), .rst(rst));

    // Decode Logic
    decode_logic dec (.a0(a0), .a1(a1), .a2(input_a2), .imm(input_imm), .func(input_func), 
                      .en_jmp(input_en_jmp), .en_uncond_jmp(input_en_uncond_jmp), 
                      .en_imm(en_imm), .en_reg_wr(input_en_reg_wr), .en_mem_wr(input_en_mem_wr), .en_mem_re(input_en_mem_re),
                      .en_rel_reg_jmp(input_en_rel_reg_jmp), .ld_code(input_ld_code), .dmem_addr_bus_use(input_dmem_addr_bus_use), 
                      .instr(instr));

    assign a2_hazard = {5{~squash}} & input_a2;
    always @(*) begin

        // Determine which value to use for the second value in the ALU operation
        if (en_imm)
            alu_input_data2 <= input_imm;
        else
            alu_input_data2 <= d1;
    end

endmodule
