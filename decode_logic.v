
module decode_logic(a0, a1, a2, imm, func, en_jmp, en_uncond_jmp, en_imm, en_reg_wr, en_mem_wr, en_mem_re, en_rel_reg_jmp, ld_code, dmem_addr_bus_use, instr);
    `include "proc_params.h"
    
    input  [31:0] instr;
    output     [`REG_BITS-1:0] a0;
    output     [`REG_BITS-1:0] a1;
    output     [`REG_BITS-1:0] a2;
    output reg [31:0] imm;
    output     [`FUNC1_BITS+`FUNC2_BITS-1:0] func;
    output reg en_jmp;
    output reg en_uncond_jmp;
    output reg en_imm;
    output reg en_reg_wr;
    output reg en_mem_wr;
    output reg en_mem_re;
    output reg en_rel_reg_jmp;
    output reg [2:0] ld_code;
    output reg dmem_addr_bus_use;

    reg [2:0] imm_pos;
    reg en_alu_str_func;

    wire [31:0] fu_imm;
    wire [31:0] fi_imm;
    wire [31:0] fs_imm;
    wire [31:0] fb_imm;
    wire [31:0] fj_imm;

    assign a0 = instr[`OPCODE_SIZE + 2*`REG_BITS + `FUNC1_BITS - 1:`OPCODE_SIZE + `REG_BITS + `FUNC1_BITS];
    assign a1 = instr[`OPCODE_SIZE + 3*`REG_BITS + `FUNC1_BITS - 1:`OPCODE_SIZE + 2*`REG_BITS + `FUNC1_BITS];
    assign a2 = instr[`OPCODE_SIZE + `REG_BITS - 1:`OPCODE_SIZE];
    assign func = {`FUNC1_BITS+`FUNC2_BITS{~en_alu_str_func}} & {instr[`OPCODE_SIZE + 3*`REG_BITS + `FUNC1_BITS + `FUNC2_BITS - 1:`OPCODE_SIZE + 3*`REG_BITS + `FUNC1_BITS], instr[`OPCODE_SIZE + `REG_BITS + `FUNC1_BITS - 1:`OPCODE_SIZE + `REG_BITS]};
        
    assign fu_imm = {instr[31:12], {12{instr[31]}}};
    assign fi_imm = {{20{instr[31]}}, instr[31:20]};
    assign fs_imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    assign fb_imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
    assign fj_imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};

    always @ (*) begin  
        case({instr[`OPCODE_SIZE-1:0]})
           `LOAD_UPPER_IMM: begin
                imm_pos <= `FORMAT_U;
                ld_code <= `IMM_LD;
                en_jmp <= 1'b0;
                en_uncond_jmp <= 1'b0;
                en_rel_reg_jmp <= 1'b0;
                en_imm <= 1'b0;
                en_reg_wr <= 1'b1;
                en_mem_wr <= 1'b0;
                en_mem_re <= 1'b0;
                en_alu_str_func <= 1'b0;
                dmem_addr_bus_use <= 1'b0;
            end
            `ADD_UPPER_IMM_PC: begin
                imm_pos <= `FORMAT_U;
                ld_code <= `PC_PIMM_LD;
                en_jmp <= 1'b0;
                en_uncond_jmp <= 1'b0;
                en_imm <= 1'b0;
                en_reg_wr <= 1'b1;
                en_mem_wr <= 1'b0;
                en_mem_re <= 1'b0;
                en_alu_str_func <= 1'b0;
                dmem_addr_bus_use <= 1'b0;
            end
            `JUMP_AND_LINK: begin
                imm_pos <= `FORMAT_J;
                ld_code <= `PC_LD;
                en_jmp <= 1'b1;
                en_uncond_jmp <= 1'b1;
                en_rel_reg_jmp <= 1'b0;
                en_imm <= 1'b1;
                en_reg_wr <= 1'b1;
                en_mem_wr <= 1'b0;
                en_mem_re <= 1'b0;
                en_alu_str_func <= 1'b0;
                dmem_addr_bus_use <= 1'b0;
            end
            `JUMP_AND_LINK_REG: begin
                imm_pos <= `FORMAT_I;
                ld_code <= `PC_LD;
                en_jmp <= 1'b1;
                en_uncond_jmp <= 1'b0;
                en_rel_reg_jmp <= 1'b1;
                en_imm <= 1'b1;
                en_reg_wr <= 1'b1;
                en_mem_wr <= 1'b0;
                en_mem_re <= 1'b0;
                en_alu_str_func <= 1'b0;
                dmem_addr_bus_use <= 1'b0;
            end
            `LOAD_OP: begin
                imm_pos <= `FORMAT_I;
                ld_code <= `MEM_LD;
                en_jmp <= 1'b0;
                en_uncond_jmp <= 1'b0;
                en_rel_reg_jmp <= 1'b0;
                en_imm <= 1'b1;
                en_reg_wr <= 1'b1;
                en_mem_wr <= 1'b0;
                en_mem_re <= 1'b1; 
                en_alu_str_func <= 1'b1;
                dmem_addr_bus_use <= 1'b1;
            end
            `STORE_OP: begin
                imm_pos <= `FORMAT_S;
                ld_code <= `NO_LD;
                en_jmp <= 1'b0;
                en_uncond_jmp <= 1'b0;
                en_rel_reg_jmp <= 1'b0;
                en_imm <= 1'b1;
                en_reg_wr <= 1'b0;
                en_mem_wr <= 1'b1;
                en_mem_re <= 1'b0;
                en_alu_str_func <= 1'b1;
                dmem_addr_bus_use <= 1'b1;
            end
            `BRANCH_OP: begin
                imm_pos <= `FORMAT_B;
                ld_code <= `NO_LD;
                en_jmp <= 1'b1;
                en_uncond_jmp <= 1'b0;
                en_rel_reg_jmp <= 1'b0;
                en_imm <= 1'b0;
                en_reg_wr <= 1'b1;
                en_mem_wr <= 1'b0;
                en_mem_re <= 1'b0;
                en_alu_str_func <= 1'b0;
                dmem_addr_bus_use <= 1'b0;
            end
            `IMM_ALU_OP: begin
                imm_pos <= `FORMAT_I;
                ld_code <= `ALU_LD;
                en_jmp <= 1'b0;
                en_uncond_jmp <= 1'b0;
                en_rel_reg_jmp <= 1'b0;
                en_imm <= 1'b1;
                en_reg_wr <= 1'b1;
                en_mem_wr <= 1'b0;
                en_mem_re <= 1'b0;
                en_alu_str_func <= 1'b0;
                dmem_addr_bus_use <= 1'b0;
            end
            `REG_ALU_OP: begin
                imm_pos <= `NO_IMM;
                ld_code <= `ALU_LD;
                en_jmp <= 1'b0;
                en_uncond_jmp <= 1'b0;
                en_rel_reg_jmp <= 1'b0;
                en_imm <= 1'b0;
                en_reg_wr <= 1'b1;
                en_mem_wr <= 1'b0;
                en_mem_re <= 1'b0;
                en_alu_str_func <= 1'b0;
                dmem_addr_bus_use <= 1'b0;
            end
            default: begin
                imm_pos <= `NO_IMM;
                ld_code <= `NO_LD;
                en_jmp <= 1'b0;
                en_uncond_jmp <= 1'b0;
                en_rel_reg_jmp <= 1'b0;
                en_imm <= 1'b0;
                en_reg_wr <= 1'b0;
                en_mem_wr <= 1'b0;
                en_mem_re <= 1'b0;
                en_alu_str_func <= 1'b0;
                dmem_addr_bus_use <= 1'b0;
            end  
       endcase

       case({imm_pos})
           `FORMAT_U: begin
               imm <= fu_imm;
           end
           `FORMAT_I: begin
               imm <= fi_imm;
           end
           `FORMAT_S: begin
               imm <= fs_imm;
           end
           `FORMAT_B: begin
               imm <= fb_imm;
           end
           `FORMAT_J: begin
               imm <= fj_imm;
           end
           default: begin
               imm <= fu_imm;
           end       
       endcase
   end

endmodule