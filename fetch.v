`timescale 1us/100ns

`include "stallmem.v"
`include "latch.v"

module fetch (curr_addr, instr_out, curr_addr_step_out, curr_addr_addval_out,
              instr_in, jump_taken, alu_bits, en_uncond_jmp, en_rel_reg_jmp, 
              en_branch, en_jmp, imm, stall, imem_ready, clk, rst);
   
    // Current Address
    output wire [31:0] curr_addr;
    // Instruction coming out of fetch stage
    output wire [31:0] instr_out;
    // Leaving Fetch Stage, Current address plus four bytes
    output wire [31:0] curr_addr_step_out;
    // Leaving Fetch Stage, Current address plus relative jump
    output wire [31:0] curr_addr_addval_out; 


    // Instruction coming directly from memory
    input wire [31:0] instr_in;
    // From Main Processor, signal that tells whether a jump will be taken or not
    input wire jump_taken;
    // From Execute, the address from the ALU
    input wire [31:0] alu_bits;
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
    // Signal designating if the instruction memory was successfully read from
    input wire imem_ready;
    // Clock and Reset 
    input wire clk, rst;

 
    // Current Address After 4 Byte Step
    wire [31:0] curr_addr_step;
    // Current Address plus relative jump
    wire [31:0] curr_addr_addval;
     
  
    // Next Address to be used put onto the cache
    reg  [31:0] next_addr;

    // Program Counter
    latch pc [31:0] (.q(curr_addr), .d(next_addr), .stall(stall | ~imem_ready), .clk(clk), .rst(rst)); 
       
    // Instruction Latch
    latch instr_latch [31:0] (.q(instr_out), .d(instr_in & {32{imem_ready}}), .stall(stall), .clk(clk), .rst(rst)); // If the memory stalls, replace out going instruction with empty instruction

    // Latch for the current address plus four bytes
    latch curr_addr_step_latch [31:0] (.q(curr_addr_step_out), .d(curr_addr_step), .stall(stall), .clk(clk), .rst(rst));

    // Latch for the current address plus the additional value
    latch curr_addr_addval_latch [31:0] (.q(curr_addr_addval_out), .d(curr_addr_addval), .stall(stall), .clk(clk), .rst(rst));

    // Latch for current address
    wire [31:0] curr_addr_conn_latch1;
    wire [31:0] curr_addr_out;
    latch curr_addr_latch1 [31:0] (.q(curr_addr_conn_latch1), .d(curr_addr), .stall(stall), .clk(clk), .rst(rst));
    latch curr_addr_latch2 [31:0] (.q(curr_addr_out), .d(curr_addr_conn_latch1), .stall(stall), .clk(clk), .rst(rst));

    assign curr_addr_step = curr_addr + 4;
    assign curr_addr_addval = curr_addr_out + imm;

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
