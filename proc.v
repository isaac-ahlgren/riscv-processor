`timescale 1us/100ns

`include "reg_file.v"
`include "decode.v"
`include "alu.v"
`include "memory2c.v"
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
   
    // Next address for the program counter
    reg [31:0] next_addr;
    // Current address from the program counter
    wire [31:0] curr_addr;
    // Current address plus relative jump
    reg [31:0] curr_addr_add_val;
    // Current address plus four bytes to get to the next instruction
    wire [31:0] curr_addr_plus_4bytes;
    // Value that will be added to the current address for the relative jump
    reg [31:0] additional_val;

    // Enable Caches
    wire enable;
    // Enable dump for memory
    wire createdump;
    wire createdump_data;
    // Write Enable for the instruction cache
    wire imem_wr;
    // Read function for the instruction cache
    wire [2:0] imem_func;
    // Instruction
    wire [31:0] instr;
    // Second value in the ALU operation
    reg [31:0] bits_b;
    // Output from ALU operation
    wire [31:0] alu_bits;
    // Bits from the data cache
    wire [31:0] dcache_bits;
    // Bits to be written to a register
    reg [31:0] reg_out_bits;
    
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

    // Enables an immediate to be added to the PC
    wire en_imm_pc_add;
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

    assign enable = 1'b1;
    assign createdump = 1'b0;
    assign createdump_data = 1'b1;
    assign imem_wr = 1'b0;
    assign imem_func = 3'b010;

    // Program Counter
    dflop pc [31:0] (.q(curr_addr), .d(next_addr), .clk(clk), .rst(rst)); 
    // Instruction Cache
    memory2c icache (.data_out(instr), .addr(curr_addr), .enable(enable), .wr(imem_wr), .createdump(createdump), .clk(clk), .rst(rst)); 
    // Decode Logic
    decode dec(.instr(instr), .a0(a0), .a1(a1), .a2(a2), .imm(imm), .func(func), .en_jmp(en_jmp), .en_uncond_jmp(en_uncond_jmp), .en_imm(en_imm), .en_reg_wr(en_reg_wr), .en_mem_wr(en_mem_wr), .en_imm_pc_add(en_imm_pc_add), .en_rel_reg_jmp(en_rel_reg_jmp), .ld_code(ld_code));
    // Register File
    reg_file regs (.a0(a0), .a1(a1), .a2(a2), .din(reg_out_bits), .reg_wr(en_reg_wr), .d0(d0), .d1(d1), .clk(clk), .rst(rst));
    // ALU
    alu a(.bits_a(d0), .bits_b(bits_b), .func(func), .out_bits(alu_bits), .compare_val(en_branch));
    // Data Cache
    memory2c dcache (.data_out(dcache_bits), .data_in(d1), .addr(alu_bits), .enable(enable), .wr(en_mem_wr), .createdump(createdump_data), .clk(clk), .rst(rst));

    assign enable = 1'b1;
    assign createdump = 1'b0;
    assign imem_wr = 1'b0;
    assign curr_addr_plus_4bytes = curr_addr + 4;
    assign curr_addr_add_val = curr_addr + additional_val;

    //always @(posedge clk) begin
    //    #1;   
    //    curr_addr_add_val = curr_addr + additional_val;
    //end

    always @(*) begin
        //curr_addr_add_val = curr_addr + additional_val;
        // Determine whether a relative jump using an immediate or using a value in a register
        if (en_imm_pc_add)
            additional_val <= imm;
        else
            additional_val <= d0;

        // Determine if a jump is to be taken
        if (en_jmp & en_rel_reg_jmp) begin
            next_addr <= alu_bits;
        end
        else if (en_jmp & (en_uncond_jmp | en_branch)) begin
            next_addr <= curr_addr_add_val;
        end
        else begin
            next_addr <= curr_addr_plus_4bytes;
        end

        // Determine which value to use for the second value in the ALU operation
        if (en_imm)
            bits_b <= imm;
        else
            bits_b <= d1;

        // Mux to Determine Register Write Back
        case({ld_code})
            `ALU_LD: begin
                 reg_out_bits <= alu_bits;
             end
            `MEM_LD: begin
                 reg_out_bits <= dcache_bits;
             end
            `IMM_LD: begin
                 reg_out_bits <= imm;
             end
             `PC_LD: begin
                 reg_out_bits <= curr_addr_plus_4bytes;
             end
             `PC_PIMM_LD: begin
                 reg_out_bits <= curr_addr_add_val;
             end
             default: begin
                 reg_out_bits <= curr_addr_plus_4bytes;
             end
        endcase
    end
endmodule
        