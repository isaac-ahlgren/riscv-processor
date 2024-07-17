`timescale 1us/100ns

`include "stallmem.v"
`include "latch.v"

module fetch (instr, curr_addr_step_out, curr_addr_addval_out, curr_addr_out, 
              icache_status, jump_taken, alu_bits, curr_addr_in, en_uncond_jmp, 
              en_rel_reg_jmp, en_branch, en_jmp, imm, stall, clk, rst);
   
    // Instruction from I-cache
    output wire [31:0] instr;
    // Leaving Fetch Stage, Current address plus four bytes
    output wire [31:0] curr_addr_step_out;
    // Leaving Fetch Stage, Current address
    output wire [31:0] curr_addr_out;
    // Leaving Fetch Stage, Current address plus relative jump
    output wire [31:0] curr_addr_addval_out; 
    // Leaving Fetch Stage, a signal that tells that a stall is occuring due to a instruction cache stall occuring at the same time as a jump
    output wire icache_status;

    // From Main Processor, signal that tells whether a jump will be taken or not
    input wire jump_taken;
    // From Execute, the address from the ALU
    input wire [31:0] alu_bits;
    // From Decode, the current address from the decode latch
    input wire [31:0] curr_addr_in; 
    // From Decode, signal that enables jumps
    input wire en_jmp;
    // From Decode, signal that enables unconditional jumps
    input wire en_uncond_jmp;
    // From Decode, signal that enables jumps using a register and an immediate
    input wire en_rel_reg_jmp;
    // From Decode, signal that enables a branch to be taken
    input wire en_branch;
    // From Decode, the immediate value from the instruction
    input wire [31:0] imm;
    // Signal that informs whether a stall is occuring from the data cache
    input wire stall; 
    // Clock and Reset 
    input wire clk, rst;

    wire ready;
    wire enable;
    wire err;
    wire createdump;
    wire imem_wr;
    wire [31:0] data_in; 
    // Instruction directly from cache
    wire [31:0] cache_instr;
    // Current Address
    wire [31:0] curr_addr;
    // Current Address After 4 Byte Step
    wire [31:0] curr_addr_step;
    // Current Address plus relative jump
    wire [31:0] curr_addr_addval;
     

    // Instruction fetched from cache (could be NOP if cache stalls)
    reg  [31:0] fetched_instr;   
    // Next Address to be used put onto the cache
    reg  [31:0] next_addr;

    // Program Counter
    latch pc [31:0] (.q(curr_addr), .d(next_addr), .stall(stall | ~ready), .clk(clk), .rst(rst)); 
    // Instruction Cache
    stallmem icache (.data_out(cache_instr), .ready(ready), .data_in(data_in), .addr(curr_addr), .enable(enable), .wr(imem_wr), .createdump(createdump), .clk(clk), .rst(rst), .err(err));
    
    // Instruction Latch
    latch instr_latch [31:0] (.q(instr), .d(fetched_instr), .stall(stall), .clk(clk), .rst(rst));

    // Latch for the current address plus four bytes
    latch curr_addr_step_latch [31:0] (.q(curr_addr_step_out), .d(curr_addr_step), .stall(stall), .clk(clk), .rst(rst));

    // Latch for the current address plus the additional value
    latch curr_addr_addval_latch [31:0] (.q(curr_addr_addval_out), .d(curr_addr_addval), .stall(stall), .clk(clk), .rst(rst));

    // Latch for current address
    wire [31:0] curr_addr_conn_latch1;
    latch curr_addr_latch1 [31:0] (.q(curr_addr_conn_latch1), .d(curr_addr), .stall(stall), .clk(clk), .rst(rst));
    latch curr_addr_latch2 [31:0] (.q(curr_addr_out), .d(curr_addr_conn_latch1), .stall(stall), .clk(clk), .rst(rst));

    assign curr_addr_step = curr_addr + 4;
    assign curr_addr_addval = curr_addr_out + imm;
    assign icache_status = jump_taken & ~ready;
    assign fetched_instr = cache_instr & {32{ready}}; // If the cache stalls, replace out going instruction with empty instruction

    // Constants
    assign createdump = 1'b1;
    assign enable = 1'b1;
    assign imem_wr = 1'b0;
    assign data_in = 32'b0;

    always @(*) begin
        // Determine if a jump is to be taken
        if (en_jmp & en_rel_reg_jmp) begin
            next_addr <= alu_bits;
        end
        else if (en_jmp & (en_uncond_jmp | en_branch)) begin
            next_addr <= curr_addr_addval;
        end
        else begin
            next_addr <= curr_addr_step;
        end

    end
endmodule
