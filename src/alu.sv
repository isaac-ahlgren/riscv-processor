`timescale 1us/100ns

module alu(
           input [31:0] data1, 
           input [31:0] data2, 
           input [9:0] func, 
           output reg [31:0] odata, 
           output reg compare_val);
    `include "proc_params.h"

    wire [31:0] compare_bits; 
    wire not_equal;
    wire lesser;

    wire [31:0] add_sub_bits;
    wire [31:0] and_bits;
    wire [31:0] or_bits;
    wire [31:0] xor_bits;

    wire [31:0] bsl_bits;
    wire [31:0] bsr_bits;

    left_barrel_shifter lbs(.idata(data1), .odata(bsl_bits), .shift_len(data2[4:0]));
    right_barrel_shifter rbs(.idata(data1), .odata(bsr_bits), .shift_len(data2[4:0]), .arithmetic(func[8]));

    assign add_sub_bits = data1 + data2;
    assign and_bits = data1 & data2;
    assign or_bits = data1 | data2;
    assign xor_bits = data1 ^ data2;
    assign compare_bits = data1 - data2;
    assign not_equal = |compare_bits;
    assign lesser = compare_bits[31]; // data1 is less than data2

    always @ (*) begin
        // Arithmetic Computation
        case({func[2:0]})
            `RISC_ADD_SUB_OP: begin
                odata = add_sub_bits; // Replace with homebrew carry-look-ahead
            end
            `RISC_AND_OP: begin
                odata = and_bits;
            end
            `RISC_OR_OP: begin
                odata = or_bits;
            end
            `RISC_XOR_OP: begin
                odata = xor_bits;
            end
            `RISC_SHIFT_LEFT: begin
                odata = bsl_bits;
            end
            `RISC_SHIFT_RIGHT: begin
                odata = bsr_bits;
            end
            default: begin
                odata = data1;
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
