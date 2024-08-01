`timescale 1us/100ns

`include "reg_file.v"
`include "decode.v"
`include "alu.v"
`include "memory2c.v"
`include "fetch.v"
    
// Macros for which value to use for a register load
`define ALU_LD         3'b001
`define MEM_LD         3'b010
`define IMM_LD         3'b011
`define PC_LD          3'b100
`define PC_PIMM_LD     3'b101
`define NO_LD          3'b000

module proc(dmem_data_out, dmem_data_in, dmem_addr, dmem_wr, dmem_ready, 
            imem_data_out, imem_data_in, imem_addr, imem_wr, imem_ready, 
            clk, rst);

    // Data from data main memory
    input wire [31:0] dmem_data_out;
    // Data going into data main memory
    output wire [31:0] dmem_data_in;
    // Address for the data main memory 
    output wire [15:0] dmem_addr;
    // Write flag for data main memory
    output wire dmem_wr;
    // Ready tp read status for data main memory
    input wire dmem_ready;
    // Data from instruction main memory
    input wire [31:0] imem_data_out;
    // Data going into instruction main memory
    output wire [31:0] imem_data_in;
    // Address for the instruction main memory 
    output wire [15:0] imem_addr;
    // Write flag for instruction main memory
    output wire imem_wr; 
    // Ready to read status for instruction main memory
    input wire imem_ready;
    input wire clk, rst;



    // Intruction
    wire [31:0] instr;
    // Output from ALU operation
    wire [31:0] alu_output_data_in;
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
    wire [31:0] imm_to_reg;
    wire [31:0] imm_to_addr;
    // Function Value (if there is one)
    wire [9:0] func;

    // Stall from data memory
    wire dmem_stall;
    // Stall from instruction memory
    wire imem_stall;
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
    // Value that determines which value is put on the register write bus
    wire [2:0] ld_code;
     
    wire [31:0] curr_addr_step;
    wire [31:0] curr_addr_addval;
    wire stall;
    wire jump_taken;
    wire control_hazard;
    wire data_hazard;

    wire [31:0] alu_output_data_as_addr;
    wire [31:0] alu_output_data_to_reg;
    latch alu_output_data_latch1 [31:0] (.q(alu_output_data_as_addr), .d(alu_output_data_in), .stall(stall), .clk(clk), .rst(rst));
    latch alu_output_data_latch2 [31:0] (.q(alu_output_data_to_reg), .d(alu_output_data_as_addr), .stall(stall), .clk(clk), .rst(rst));

    wire [31:0] dmem_data_out_to_reg;
    latch dmem_data_out_latch [31:0] (.q(dmem_data_out_to_reg), .d(dmem_data_out), .stall(stall), .clk(clk), .rst(rst));

    hazards_controller hazards(.control_hazard(control_hazard), .data_hazard(data_hazard), .stall(stall), 
                               .jump_taken(jump_taken), .dmem_stall(dmem_stall), .imem_stall(imem_stall),
                               .a0(a0), .a1(a1), .a2(a2_hazard), .clk(clk), .rst(rst));
    assign jump_taken = (en_jmp) & (en_rel_reg_jmp | en_uncond_jmp | en_branch);
    assign imem_stall = jump_taken & ~imem_ready;
    assign dmem_stall = ~dmem_ready;   

    // Fetch Stage
    fetch fet (.curr_addr(imem_addr), .instr_out(instr), .curr_addr_step_out(curr_addr_step), .curr_addr_addval_out(curr_addr_addval),
               .instr_in(imem_data_out), .jump_taken(jump_taken), .alu_bits(alu_output_data_in), .en_uncond_jmp(en_uncond_jmp), 
               .en_rel_reg_jmp(en_rel_reg_jmp), .en_branch(en_branch), .en_jmp(en_jmp), .imm(imm_to_addr), .stall(stall | data_hazard), 
               .imem_ready(imem_ready), .clk(clk), .rst(rst));
    // Decode Stage
    decode_register_select drs(.a0(a0), .a1(a1), .a2(a2), .a2_hazard(a2_hazard), .imm_to_reg(imm_to_reg), .imm_to_addr(imm_to_addr),
                           .func(func), .en_jmp(en_jmp), .en_uncond_jmp(en_uncond_jmp), .en_rel_reg_jmp(en_rel_reg_jmp), .en_mem_wr(dmem_wr), 
                           .ld_code(ld_code), .alu_data1(alu_data1), .alu_data2(alu_data2), .data_to_mem(dmem_data_in), .en_reg_wr(en_reg_wr), 
                           .instr(instr), .d0(d0), .d1(d1), .stall(stall), .squash(data_hazard | control_hazard), .clk(clk), .rst(rst));

    // ALU
    alu a(.bits_a(alu_data1), .bits_b(alu_data2), .func(func), .out_bits(alu_output_data_in), .compare_val(en_branch));

    // Register File
    reg_file regs (.a0(a0), .a1(a1), .a2(a2), 
                   .din(data_to_reg), .reg_wr(en_reg_wr), 
                   .d0(d0), .d1(d1), .clk(clk), .rst(rst));

    assign dmem_addr = alu_output_data_as_addr;

    always @(*) begin

        // Mux to Determine Register Write Back
        case({ld_code})
            `ALU_LD: begin
                 data_to_reg <= alu_output_data_to_reg;
             end
            `MEM_LD: begin
                 data_to_reg <= dmem_data_out_to_reg;
             end
            `IMM_LD: begin
                 data_to_reg <= imm_to_reg;
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
        