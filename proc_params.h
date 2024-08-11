
// Macros for bit sizes in instructions
`define REG_BITS 5
`define OPCODE_SIZE 7
`define FUNC1_BITS 3
`define FUNC2_BITS 7

// Macros for opcodes
`define LOAD_UPPER_IMM       7'b0110111
`define ADD_UPPER_IMM_PC     7'b0010111
`define JUMP_AND_LINK        7'b1101111
`define JUMP_AND_LINK_REG    7'b1100111
`define LOAD_OP              7'b0000011
`define STORE_OP             7'b0100011
`define BRANCH_OP            7'b1100011
`define IMM_ALU_OP           7'b0010011
`define REG_ALU_OP           7'b0110011

// Macros for format of immediate
`define FORMAT_U       3'b001
`define FORMAT_I       3'b010
`define FORMAT_S       3'b011
`define FORMAT_B       3'b100
`define FORMAT_J       3'b101
`define NO_IMM         3'b000

// Macros for which value to use for a register load
`define ALU_LD         3'b001
`define MEM_LD         3'b010
`define IMM_LD         3'b011
`define PC_LD          3'b100
`define PC_PIMM_LD     3'b101
`define NO_LD          3'b000

// Macros for function codes in the ALU
`define RISC_ADD_SUB_OP     3'b000
`define RISC_SHIFT_LEFT     3'b001
`define RISC_SHIFT_RIGHT    3'b101
`define RISC_XOR_OP         3'b100
`define RISC_OR_OP          3'b110
`define RISC_AND_OP         3'b111

// Macros for branch type codes
`define BEQ                 3'b000
`define BNE                 3'b001
`define BLT                 3'b100
`define BGE                 3'b101
`define BLTU                3'b110
`define BGETU               3'b111