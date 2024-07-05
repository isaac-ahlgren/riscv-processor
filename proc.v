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
    // Second value in the ALU operation
    reg [31:0] bits_b;
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
    // Output data from register file
    wire [31:0] d0;
    wire [31:0] d1;
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
    // Enables the use of immediates
    wire en_imm;
    // Enables a write to the register
    wire en_reg_wr;
    // Enables a write to memory
    wire en_mem_wr;
    // Value that determines which value is put on the register write bus
    wire [2:0] ld_code;
     
    wire [31:0] curr_addr_step;
    wire [31:0] curr_addr_addval;
    wire [31:0] curr_addr;
    wire icache_stall;
    wire dcache_stall;
    wire stall;
    wire jump_taken;
    wire data_to_mem;

    assign enable = 1'b1;
    assign createdump_data = 1'b1;
    assign dcache_stall = 1'b0;

    wire control_hazard;
    wire control_hazard_latch1_conn;
    wire control_hazard_latch2_conn;
    latch control_hazard_latch1 (.q(control_hazard_latch1_conn), .d(control_hazard), .stall(stall), .clk(clk), .rst(rst));
    latch control_hazard_latch2 (.q(control_hazard_latch2_conn), .d(control_hazard_latch1_conn), .stall(stall), .clk(clk), .rst(rst));

    assign control_hazard = ~jump_taken;
    assign stall = dcache_stall | icache_stall;
    assign jump_taken = (en_jmp & control_hazard_latch2_conn) & (en_rel_reg_jmp | en_uncond_jmp | en_branch);      

    // Fetch Stage
    fetch fet (.instr(instr), .curr_addr_step_out(curr_addr_step), .curr_addr_addval_out(curr_addr_addval), .curr_addr_out(curr_addr), 
               .icache_status(icache_stall), .jump_taken(jump_taken), .alu_bits(alu_bits), .curr_addr_in(curr_addr), .en_uncond_jmp(en_uncond_jmp), 
               .en_rel_reg_jmp(en_rel_reg_jmp), .en_branch(en_branch), .en_jmp(en_jmp & control_hazard_latch2_conn), .imm(imm), .stall(stall), .clk(clk), 
               .rst(rst));
    // Decode Stage
    decode_register_select(.imm(imm), .func(func), .en_jmp(en_jmp), .en_uncond_jmp(en_uncond_jmp), .en_rel_reg_jmp(en_rel_reg_jmp),
                           .en_mem_wr(en_mem_wr), .ld_code(ld_code), .alu_data1(d0), .alu_data2(d1), .data_to_mem(data_to_mem), 
                           .instr(instr), .data_to_reg(data_to_reg), .stall(stall), .control_hazard(control_hazard_latch2_conn), 
                           .clk(clk), .rst(rst));
    // ALU
    alu a(.bits_a(d0), .bits_b(bits_b), .func(func), .out_bits(alu_bits), .compare_val(en_branch));
    // Data Cache
    memory2c dcache (.data_out(dcache_bits), .data_in(data_to_mem), .addr(alu_bits), .enable(enable), .wr(en_mem_wr & control_hazard_latch2_conn), .createdump(createdump), .clk(clk), .rst(rst));

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
        