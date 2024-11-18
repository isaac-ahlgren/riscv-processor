`timescale 1us/100ns

module proc(input [31:0] data_out, 
            output [31:0] data_in, 
            output [31:0] addr, 
            output omem_wr, 
            output omem_re, 
            input mem_ready, 
            input clk, 
            input rst);

    `include "proc_params.h"

    // Intruction
    wire [31:0] instr;
    // Output from ALU operation
    wire [31:0] ialu_odata;
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
    wire first_stage_stall;
    wire jump_taken;
    wire control_hazard;
    wire data_hazard;
    wire squash;

    wire [31:0] imem_data_out;
    wire [31:0] imem_addr;
    wire imem_ready;
    wire [31:0] dmem_data_out; 
    wire [31:0] dmem_addr;
    wire dmem_ready;
    wire mem_wr;
    wire mem_re;

    memory_system ms (.imem_data_out(imem_data_out), 
                      .dmem_data_out(dmem_data_out), 
                      .data_out(data_out), 
                      .imem_stall(imem_stall), 
                      .dmem_stall(dmem_stall), 
                      .stall(stall),
                      .first_stage_stall(first_stage_stall),
                      .squash(squash),
                      .mem_ready(mem_ready),
                      .jump_taken(jump_taken),
                      .imem_addr(imem_addr), 
                      .dmem_addr(dmem_addr), 
                      .mem_addr(addr), 
                      .en_mem_re(mem_re), 
                      .en_mem_wr(mem_wr), 
                      .en_ext_mem_re(omem_re), 
                      .en_ext_mem_wr(omem_wr), 
                      .data_hazard(data_hazard), 
                      .control_hazard(control_hazard), 
                      .clk(clk), 
                      .rst(rst));

    hazards_controller hazards(.control_hazard(control_hazard), 
                               .data_hazard(data_hazard), 
                               .jump_taken(jump_taken), 
                               .a0(a0), 
                               .a1(a1), 
                               .a2(a2_hazard),
                               .stall(stall),
                               .clk(clk), 
                               .rst(rst));

    // Fetch Stage
    fetch fet (.curr_addr(imem_addr), 
               .oinstr(instr), 
               .ocurr_addr_step(curr_addr_step), 
               .ocurr_addr_reljmp(curr_addr_addval),
               .iinstr(imem_data_out), 
               .jump_taken(jump_taken), 
               .addr_rel_reg(ialu_odata), 
               .en_uncond_jmp(en_uncond_jmp), 
               .en_rel_reg_jmp(en_rel_reg_jmp), 
               .en_branch(en_branch), 
               .en_jmp(en_jmp), 
               .imm(imm_to_addr), 
               .stall(first_stage_stall), 
               .imem_stall(imem_stall), 
               .clk(clk), 
               .rst(rst));

    // Decode Stage
    decode_register_select drs(.a0(a0), 
                               .a1(a1), 
                               .a2(a2), 
                               .a2_hazard(a2_hazard), 
                               .imm_to_reg(imm_to_reg), 
                               .imm_to_addr(imm_to_addr),
                               .func(func), 
                               .en_jmp(en_jmp), 
                               .en_uncond_jmp(en_uncond_jmp), 
                               .en_rel_reg_jmp(en_rel_reg_jmp), 
                               .en_mem_wr(mem_wr), 
                               .en_mem_re(mem_re),
                               .ld_code(ld_code), 
                               .alu_data1(alu_data1), 
                               .alu_data2(alu_data2), 
                               .data_to_mem(data_in),
                               .en_reg_wr(en_reg_wr), 
                               .instr(instr), 
                               .d0(d0), 
                               .d1(d1), 
                               .stall(stall), 
                               .squash(squash), 
                               .clk(clk), 
                               .rst(rst));

    // ALU
    alu a(.data1(alu_data1), 
          .data2(alu_data2), 
          .func(func), 
          .odata(ialu_odata), 
          .compare_val(en_branch));

    // Register File
    reg_file regs (.a0(a0), 
                   .a1(a1), 
                   .a2(a2), 
                   .din(data_to_reg), 
                   .reg_wr(en_reg_wr), 
                   .d0(d0), 
                   .d1(d1), 
                   .clk(clk), 
                   .rst(rst));

    wire [31:0] alu_odata_as_addr;
    wire [31:0] alu_odata_to_reg;
    pipeline_latch alu_output_data_latch1 [31:0] (.q(alu_odata_as_addr), .d(ialu_odata), .stall(stall), .clk(clk), .rst(rst));
    pipeline_latch alu_output_data_latch2 [31:0] (.q(alu_odata_to_reg), .d(alu_odata_as_addr), .stall(stall), .clk(clk), .rst(rst));

    assign dmem_addr = alu_odata_as_addr;

    assign jump_taken = (en_jmp) & (en_rel_reg_jmp | en_uncond_jmp | en_branch);

    always @(*) begin

        // Mux to Determine Register Write Back
        case({ld_code})
            `ALU_LD: begin
                 data_to_reg <= alu_odata_to_reg;
             end
            `MEM_LD: begin
                 data_to_reg <= dmem_data_out;
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
        