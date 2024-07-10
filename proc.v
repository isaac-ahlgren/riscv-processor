`timescale 1us/100ns

`include "reg_file.v"
`include "decode.v"
`include "alu.v"
`include "memory2c.v"
`include "fetch.v"
`include "dff.v"
    
// Macros for which value to use for a register load
`define ALU_LD         3'b001
`define MEM_LD         3'b010
`define IMM_LD         3'b011
`define PC_LD          3'b100
`define PC_PIMM_LD     3'b101
`define NO_LD          3'b000

module proc(clk, rst);
    input wire clk, rst;

    // Enable Caches
    wire enable;
    // Instruction
    wire [31:0] instr;
    // Output from ALU operation
    wire [31:0] alu_bits;
    // Bits from the data cache
    wire [31:0] dcache_bits;
    // Data to be written to a register
    reg [31:0] data_to_reg;
    
    // Register Numbers
    wire [4:0] a0;
    wire [4:0] a1;
    wire [4:0] a2;
    wire [4:0] a2_hazard;
    // Output data from register file
    wire [31:0] d0;
    wire [31:0] d1;
    // Data to be used in ALU comutation
    wire [31:0] alu_data1;
    wire [31:0] alu_data2;
    // Immediate Value (if there is one)
    wire [31:0] imm;
    // Function Value (if there is one)
    wire [9:0] func;

    // Enables if a jump can be taken
    wire en_jmp;
    // Enables unconditional jumps
    wire en_uncond_jmp;
    // Enables unconditional jump relative to value in a register
    wire en_rel_reg_jmp;
    // Enables if a branch is going to be be taken or not
    wire en_branch;
    // Enables a write to the register
    wire en_reg_wr;
    // Enables a write to memory
    wire en_mem_wr;
    // Value that determines which value is put on the register write bus
    wire [2:0] ld_code;
     
    wire [31:0] curr_addr_step;
    wire [31:0] curr_addr_addval;
    wire [31:0] curr_addr;
    wire [31:0] data_to_mem;
    wire icache_stall;
    wire dcache_stall;
    wire stall;
    wire jump_taken;
    wire control_hazard;
    wire data_hazard;

    assign enable = 1'b1;
    assign createdump_data = 1'b1;
    assign dcache_stall = 1'b0;

    hazards_controller hazards(.control_hazard(control_hazard), .data_hazard(data_hazard), .stall(stall), 
                               .jump_taken(jump_taken), .dcache_stall(dcache_stall), .icache_stall(icache_stall), 
                               .a0(a0), .a1(a1), .a2(a2_hazard), .clk(clk), .rst(rst));
    assign jump_taken = (en_jmp) & (en_rel_reg_jmp | en_uncond_jmp | en_branch);      

    // Fetch Stage
    fetch fet (.instr(instr), .curr_addr_step_out(curr_addr_step), .curr_addr_addval_out(curr_addr_addval),
               .curr_addr_out(curr_addr), .icache_status(icache_stall), .jump_taken(jump_taken), 
               .alu_bits(alu_bits), .curr_addr_in(curr_addr), .en_uncond_jmp(en_uncond_jmp), 
               .en_rel_reg_jmp(en_rel_reg_jmp), .en_branch(en_branch), .en_jmp(en_jmp), 
               .imm(imm), .stall(stall | data_hazard), .clk(clk), .rst(rst));
    // Decode Stage
    decode_register_select drs(.a0(a0), .a1(a1), .a2(a2), .a2_hazard(a2_hazard), .imm(imm), .func(func), .en_jmp(en_jmp), .en_uncond_jmp(en_uncond_jmp), 
                           .en_rel_reg_jmp(en_rel_reg_jmp), .en_mem_wr(en_mem_wr), .ld_code(ld_code), .alu_data1(alu_data1), 
                           .alu_data2(alu_data2), .data_to_mem(data_to_mem), .en_reg_wr(en_reg_wr), .instr(instr), .d0(d0), .d1(d1), 
                           .stall(stall), .squash(data_hazard | control_hazard), .clk(clk), .rst(rst));
    // ALU
    alu a(.bits_a(alu_data1), .bits_b(alu_data2), .func(func), .out_bits(alu_bits), .compare_val(en_branch));
    // Register File
    reg_file regs (.a0(a0), .a1(a1), .a2(a2), 
                   .din(data_to_reg), .reg_wr(en_reg_wr), 
                   .d0(d0), .d1(d1), .clk(clk), .rst(rst));
    // Data Cache
    memory2c dcache (.data_out(dcache_bits), .data_in(data_to_mem), .addr(alu_bits), .enable(enable), 
                     .wr(en_mem_wr), .createdump(createdump_data), .clk(clk), 
                     .rst(rst));

    assign enable = 1'b1;
    assign createdump = 1'b0;
    assign imem_wr = 1'b0;

    always @(*) begin

        // Mux to Determine Register Write Back
        case({ld_code})
            `ALU_LD: begin
                 data_to_reg <= alu_bits;
             end
            `MEM_LD: begin
                 data_to_reg <= dcache_bits;
             end
            `IMM_LD: begin
                 data_to_reg <= imm;
             end
             `PC_LD: begin
                 data_to_reg <= curr_addr_step;
             end
             `PC_PIMM_LD: begin
                 data_to_reg <= curr_addr_addval;
             end
             default: begin
                 data_to_reg <= curr_addr_step;
             end
        endcase
    end
endmodule
        