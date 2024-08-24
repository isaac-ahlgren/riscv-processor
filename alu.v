`timescale 1us/100ns

module alu(bits_a, bits_b, func, out_bits, compare_val);
    `include "proc_params.h"

    input [31:0] bits_a;
    input [31:0] bits_b;
    input [9:0] func;
    output reg [31:0] out_bits;
    output reg compare_val;

    wire [31:0] compare_bits; 
    wire not_equal;
    wire lesser;

    wire [31:0] add_sub_bits;
    wire [31:0] and_bits;
    wire [31:0] or_bits;
    wire [31:0] xor_bits;

    wire [31:0] bsl_bits;
    wire [31:0] bsr_bits;

    left_barrel_shifter lbs(.in_bits(bits_a), .out_bits(bsl_bits), .shift_len(bits_b[4:0]));
    right_barrel_shifter rbs(.in_bits(bits_a), .out_bits(bsr_bits), .shift_len(bits_b[4:0]), .arithmetic(func[8]));

    assign add_sub_bits = bits_a + bits_b;
    assign and_bits = bits_a & bits_b;
    assign or_bits = bits_a | bits_b;
    assign xor_bits = bits_a ^ bits_b;
    assign compare_bits = bits_a - bits_b;
    assign not_equal = |compare_bits;
    assign lesser = compare_bits[31]; // bits_a is less than bits_b

    always @ (*) begin
        // Arithmetic Computation
        case({func[2:0]})
            `RISC_ADD_SUB_OP: begin
                out_bits = add_sub_bits; // Replace with homebrew carry-look-ahead
            end
            `RISC_AND_OP: begin
                out_bits = and_bits;
            end
            `RISC_OR_OP: begin
                out_bits = or_bits;
            end
            `RISC_XOR_OP: begin
                out_bits = xor_bits;
            end
            `RISC_SHIFT_LEFT: begin
                out_bits = bsl_bits;
            end
            `RISC_SHIFT_RIGHT: begin
                out_bits = bsr_bits;
            end
            default: begin
                out_bits = bits_a;
            end
        endcase
    
        // Comparative Computation
        case ({func[2:0]})
            `BEQ: begin
                compare_val = ~not_equal;
            end
            `BNE: begin
                compare_val = not_equal;
            end
            `BLTU: begin
                compare_val = not_equal & lesser;
            end
            `BLT: begin
                compare_val = not_equal & lesser;
            end
            `BGE: begin
                compare_val = ~not_equal | ~lesser;
            end
            `BGETU: begin
                compare_val = ~not_equal | ~lesser;
            end
            default: begin
                compare_val = not_equal;
            end          
        endcase
    end
endmodule
