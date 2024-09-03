`timescale 1us/100ns

module fetch (
              output [31:0] curr_addr,           // Current Address
              output [31:0] oinstr,              // Instruction coming out of fetch stage
              output [31:0] ocurr_addr_step,     // Current address plus four bytes
              output [31:0] ocurr_addr_reljmp,   // Current address plus relative jump
              input [31:0] iinstr,               // Instruction coming directly from cache
              input jump_taken,                  // Signal telling whether a jump will be taken or not
              input [31:0] addr_rel_reg,         // Relative from register jump address
              input en_uncond_jmp,               // Signal for unconditional jumps
              input en_rel_reg_jmp,              // Signal for jumps using a register and an immediate
              input en_branch,                   // Signal for a branch to be taken
              input en_jmp,                      // Signal that enables jumps
              input [31:0] imm,                  // The immediate value from the instruction
              input stall,                       // Signal for a full pipeline a stall is occuring
              input imem_stall,                  // Signal for specifcally a stall due to instruction cache
              input clk,                         // Clock
              input rst);                        // Reset
 
    // Current Address After 4 Byte Step
    wire [31:0] curr_addr_step;
    // Current Address plus relative jump
    wire [31:0] curr_addr_addval;
  
    // Next Address to be used put onto the cache
    reg  [31:0] next_addr;

    // Program Counter
    pipeline_latch pc [31:0] (.q(curr_addr), .d(next_addr), .stall(stall | imem_stall), .clk(clk), .rst(rst)); 
       
    // Instruction Latch
    pipeline_latch instr_latch [31:0] (.q(oinstr), .d(iinstr), .stall(stall), .clk(clk), .rst(rst));

    // Latch for the current address plus four bytes
    wire [31:0] curr_addr_step_conn_latch1;
    wire [31:0] curr_addr_step_conn_latch2;
    wire [31:0] curr_addr_step_conn_latch3;
    pipeline_latch curr_addr_step_latch1 [31:0] (.q(curr_addr_step_conn_latch1), .d(curr_addr_step), .stall(stall), .clk(clk), .rst(rst));
    pipeline_latch curr_addr_step_latch2 [31:0] (.q(curr_addr_step_conn_latch2), .d(curr_addr_step_conn_latch1), .stall(stall), .clk(clk), .rst(rst));
    pipeline_latch curr_addr_step_latch3 [31:0] (.q(curr_addr_step_conn_latch3), .d(curr_addr_step_conn_latch2), .stall(stall), .clk(clk), .rst(rst));
    pipeline_latch curr_addr_step_latch4 [31:0] (.q(ocurr_addr_step), .d(curr_addr_step_conn_latch3), .stall(stall), .clk(clk), .rst(rst));

    // Latch for the current address plus the additional value
    wire [31:0] curr_addr_addval_conn_latch1;
    pipeline_latch curr_addr_addval_latch1 [31:0] (.q(curr_addr_addval_conn_latch1), .d(curr_addr_addval), .stall(stall), .clk(clk), .rst(rst));
    pipeline_latch curr_addr_addval_latch2 [31:0] (.q(ocurr_addr_reljmp), .d(curr_addr_addval_conn_latch1), .stall(stall), .clk(clk), .rst(rst));

    // Latch for current address
    wire [31:0] curr_addr_conn_latch1;
    wire [31:0] curr_addr_out;
    pipeline_latch curr_addr_latch1 [31:0] (.q(curr_addr_conn_latch1), .d(curr_addr), .stall(stall), .clk(clk), .rst(rst));
    pipeline_latch curr_addr_latch2 [31:0] (.q(curr_addr_out), .d(curr_addr_conn_latch1), .stall(stall), .clk(clk), .rst(rst));

    assign curr_addr_step = curr_addr + 4;
    assign curr_addr_addval = curr_addr_out + imm;

    always @(*) begin
        // Determine if a jump is to be taken
        if (en_jmp & en_rel_reg_jmp) begin
            next_addr <= addr_rel_reg;
        end
        else if (en_jmp & (en_uncond_jmp | en_branch)) begin
            next_addr <= curr_addr_addval;
        end
        else begin
            next_addr <= curr_addr_step;
        end

    end
endmodule
