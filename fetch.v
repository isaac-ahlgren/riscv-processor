
module fetch (instr, curr_addr_step, curr_addr_addval, curr_addr_fetch, alu_bits, reg_addr, en_uncond_jmp, en_reg_jmp, 
              en_branch, en_imm_pc_add, imm, d1, clk, rst);
   
    // Instruction from I-cache
    output wire [31:0] instr;
    // Leaving Fetch Stage Current address plus four bytes
    output wire [31:0] curr_addr_step_out;
    // Leaving Fetch Stage Current address plus relative jump
    output reg [31:0] curr_addr_addval_out;
    // Leaving Fetch Stage Current address
    output wire [31:0] curr_addr_out; 

    // From Execute, the address from the ALU
    input wire alu_bits; 
    // From Decode, signal that enables jumps
    input wire en_jmp;
    // From Decode, signal that enables unconditional jumps
    input wire en_uncond_jmp;
    // From Decode, signal that enables jumps using a register
    input wire en_reg_jmp;
    // From Decode, signal that enables a branch to be taken
    input wire en_branch;
    // From Decode, signal that enables the immediate value to be used for a relative PC add
    input wire en_imm_pc_add; 
    // From Decode, the immediate value from the instruction
    input wire [31:0] imm;
    // From Decode, the data to the second register
    input wire [31:0] d1;
     // Clock and Reset 
    input wire clk, rst;

    // Value that will be added to the current address for the relative jump
    reg [31:0] additional_val;
    assign curr_addr_plus_4bytes = curr_addr + 4;
    assign curr_addr_add_val = curr_addr + additional_val;
    
    always @(*) begin
        // Determine whether a relative jump using an immediate or using a value in a register
        if (en_imm_pc_add)
            additional_val <= imm;
        else
            additional_val <= d0;