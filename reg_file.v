
`include "reg_dff.v"

`define REG_BITS 5
`define OPCODE_SIZE 7
`define REG_NUM     32

module reg_file(a0, a1, a2, din, reg_wr, d0, d1, clk, rst);
     input clk;
     input rst;
     input [`REG_BITS-1:0] a0;
     input [`REG_BITS-1:0] a1;
     input [`REG_BITS-1:0] a2;
     input [31:0] din;
     input reg_wr;
     output reg [31:0] d0;
     output reg [31:0] d1;
     wire [31:0] qn [`REG_NUM-2:0];
     reg [`REG_NUM-2:0] we;
 
     // registers x1-x31, x0 is the zero register (always holds zero)
     reg_dflop x1  [31:0](.q(qn[0]),  .d(din), .we(we[0]),  .clk(clk), .rst(rst));
     reg_dflop x2  [31:0](.q(qn[1]),  .d(din), .we(we[1]),  .clk(clk), .rst(rst));
     reg_dflop x3  [31:0](.q(qn[2]),  .d(din), .we(we[2]),  .clk(clk), .rst(rst));
     reg_dflop x4  [31:0](.q(qn[3]),  .d(din), .we(we[3]),  .clk(clk), .rst(rst));
     reg_dflop x5  [31:0](.q(qn[4]),  .d(din), .we(we[4]),  .clk(clk), .rst(rst));
     reg_dflop x6  [31:0](.q(qn[5]),  .d(din), .we(we[5]),  .clk(clk), .rst(rst));
     reg_dflop x7  [31:0](.q(qn[6]),  .d(din), .we(we[6]),  .clk(clk), .rst(rst));
     reg_dflop x8  [31:0](.q(qn[7]),  .d(din), .we(we[7]),  .clk(clk), .rst(rst));
     reg_dflop x9  [31:0](.q(qn[8]),  .d(din), .we(we[8]),  .clk(clk), .rst(rst));
     reg_dflop x10 [31:0](.q(qn[9]),  .d(din), .we(we[9]),  .clk(clk), .rst(rst));
     reg_dflop x11 [31:0](.q(qn[10]), .d(din), .we(we[10]), .clk(clk), .rst(rst));
     reg_dflop x12 [31:0](.q(qn[11]), .d(din), .we(we[11]), .clk(clk), .rst(rst));
     reg_dflop x13 [31:0](.q(qn[12]), .d(din), .we(we[12]), .clk(clk), .rst(rst));
     reg_dflop x14 [31:0](.q(qn[13]), .d(din), .we(we[13]), .clk(clk), .rst(rst));
     reg_dflop x15 [31:0](.q(qn[14]), .d(din), .we(we[14]), .clk(clk), .rst(rst));
     reg_dflop x16 [31:0](.q(qn[15]), .d(din), .we(we[15]), .clk(clk), .rst(rst));
     reg_dflop x17 [31:0](.q(qn[16]), .d(din), .we(we[16]), .clk(clk), .rst(rst));
     reg_dflop x18 [31:0](.q(qn[17]), .d(din), .we(we[17]), .clk(clk), .rst(rst));
     reg_dflop x19 [31:0](.q(qn[18]), .d(din), .we(we[18]), .clk(clk), .rst(rst));
     reg_dflop x20 [31:0](.q(qn[19]), .d(din), .we(we[19]), .clk(clk), .rst(rst));
     reg_dflop x21 [31:0](.q(qn[20]), .d(din), .we(we[20]), .clk(clk), .rst(rst));
     reg_dflop x22 [31:0](.q(qn[21]), .d(din), .we(we[21]), .clk(clk), .rst(rst));
     reg_dflop x23 [31:0](.q(qn[22]), .d(din), .we(we[22]), .clk(clk), .rst(rst));
     reg_dflop x24 [31:0](.q(qn[23]), .d(din), .we(we[23]), .clk(clk), .rst(rst));
     reg_dflop x25 [31:0](.q(qn[24]), .d(din), .we(we[24]), .clk(clk), .rst(rst));
     reg_dflop x26 [31:0](.q(qn[25]), .d(din), .we(we[25]), .clk(clk), .rst(rst));
     reg_dflop x27 [31:0](.q(qn[26]), .d(din), .we(we[26]), .clk(clk), .rst(rst));
     reg_dflop x28 [31:0](.q(qn[27]), .d(din), .we(we[27]), .clk(clk), .rst(rst));
     reg_dflop x29 [31:0](.q(qn[28]), .d(din), .we(we[28]), .clk(clk), .rst(rst));
     reg_dflop x30 [31:0](.q(qn[29]), .d(din), .we(we[29]), .clk(clk), .rst(rst));
     reg_dflop x31 [31:0](.q(qn[30]), .d(din), .we(we[30]), .clk(clk), .rst(rst));

     // mux for reg value for d0
     always @ (*) begin
         case({a0})
            5'd1: begin
                d0 = qn[0];
            end
            5'd2: begin
                d0 = qn[1];
            end
            5'd3: begin
                d0 = qn[2];
            end
            5'd4: begin
                d0 = qn[3];
            end
            5'd5: begin
                d0 = qn[4];
            end
            5'd6: begin
                d0 = qn[5];
            end
            5'd7: begin
                d0 = qn[6];
            end
            5'd8: begin
                d0 = qn[7];
            end
            5'd9: begin
                d0 = qn[8];
            end
            5'd10: begin
                d0 = qn[9];
            end
            5'd11: begin
                d0 = qn[10];
            end
            5'd12: begin
                d0 = qn[11];
            end
            5'd13: begin
                d0 = qn[12];
            end
            5'd14: begin
                d0 = qn[13];
            end
            5'd15: begin
                d0 = qn[14];
            end
            5'd16: begin
                d0 = qn[15];
            end
            5'd17: begin
                d0 = qn[16];
            end
            5'd18: begin
                d0 = qn[17];
            end
            5'd19: begin
                d0 = qn[18];
            end
            5'd20: begin
                d0 = qn[19];
            end
            5'd21: begin
                d0 = qn[20];
            end
            5'd22: begin
                d0 = qn[21];
            end
            5'd23: begin
                d0 = qn[22];
            end
            5'd24: begin
                d0 = qn[23];
            end
            5'd25: begin
                d0 = qn[24];
            end
            5'd26: begin
                d0 = qn[25];
            end
            5'd27: begin
                d0 = qn[26];
            end
            5'd28: begin
                d0 = qn[27];
            end
            5'd29: begin
                d0 = qn[28];
            end
            5'd30: begin
                d0 = qn[29];
            end
            5'd31: begin
                d0 = qn[30];
            end
            default: begin
                d0 = 32'b0;
            end
         endcase

         // mux for reg value for d1
         case({a1})
            5'd1: begin
                d1 = qn[0];
            end
            5'd2: begin
                d1 = qn[1];
            end
            5'd3: begin
                d1 = qn[2];
            end
            5'd4: begin
                d1 = qn[3];
            end
            5'd5: begin
                d1 = qn[4];
            end
            5'd6: begin
                d1 = qn[5];
            end
            5'd7: begin
                d1 = qn[6];
            end
            5'd8: begin
                d1 = qn[7];
            end
            5'd9: begin
                d1 = qn[8];
            end
            5'd10: begin
                d1 = qn[9];
            end
            5'd11: begin
                d1 = qn[10];
            end
            5'd12: begin
                d1 = qn[11];
            end
            5'd13: begin
                d1 = qn[12];
            end
            5'd14: begin
                d1 = qn[13];
            end
            5'd15: begin
                d1 = qn[14];
            end
            5'd16: begin
                d1 = qn[15];
            end
            5'd17: begin
                d1 = qn[16];
            end
            5'd18: begin
                d1 = qn[17];
            end
            5'd19: begin
                d1 = qn[18];
            end
            5'd20: begin
                d1 = qn[19];
            end
            5'd21: begin
                d1 = qn[20];
            end
            5'd22: begin
                d1 = qn[21];
            end
            5'd23: begin
                d1 = qn[22];
            end
            5'd24: begin
                d1 = qn[23];
            end
            5'd25: begin
                d1 = qn[24];
            end
            5'd26: begin
                d1 = qn[25];
            end
            5'd27: begin
                d1 = qn[26];
            end
            5'd28: begin
                d1 = qn[27];
            end
            5'd29: begin
                d1 = qn[28];
            end
            5'd30: begin
                d1 = qn[29];
            end
            5'd31: begin
                d1 = qn[30];
            end
            default: begin
                d1 = 32'b0;
            end
         endcase

         case({a2 & {`REG_BITS{reg_wr}} })
            5'd1: begin
                we = 31'b0000000000000000000000000000001;
            end
            5'd2: begin
                we = 31'b0000000000000000000000000000010;
            end
            5'd3: begin
                we = 31'b0000000000000000000000000000100;
            end
            5'd4: begin
                we = 31'b0000000000000000000000000001000;
            end
            5'd5: begin
                we = 31'b0000000000000000000000000010000;
            end
            5'd6: begin
                we = 31'b0000000000000000000000000100000;
            end
            5'd7: begin
                we = 31'b0000000000000000000000001000000;
            end
            5'd8: begin
                we = 31'b0000000000000000000000010000000;
            end
            5'd9: begin
                we = 31'b0000000000000000000000100000000;
            end
            5'd10: begin
                we = 31'b0000000000000000000001000000000;
            end
            5'd11: begin
                we = 31'b0000000000000000000010000000000;
            end
            5'd12: begin
                we = 31'b0000000000000000000100000000000;
            end
            5'd13: begin
                we = 31'b0000000000000000001000000000000;
            end
            5'd14: begin
                we = 31'b0000000000000000010000000000000;
            end
            5'd15: begin
                we = 31'b0000000000000000100000000000000;
            end
            5'd16: begin
                we = 31'b0000000000000001000000000000000;
            end
            5'd17: begin
                we = 31'b0000000000000010000000000000000;
            end
            5'd18: begin
                we = 31'b0000000000000100000000000000000;
            end
            5'd19: begin
                we = 31'b0000000000001000000000000000000;
            end
            5'd20: begin
                we = 31'b0000000000010000000000000000000;
            end
            5'd21: begin
                we = 31'b0000000000100000000000000000000;
            end
            5'd22: begin
                we = 31'b0000000001000000000000000000000;
            end
            5'd23: begin
                we = 31'b0000000010000000000000000000000;
            end
            5'd24: begin
                we = 31'b0000000100000000000000000000000;
            end
            5'd25: begin
                we = 31'b0000001000000000000000000000000;
            end
            5'd26: begin
                we = 31'b0000010000000000000000000000000;
            end
            5'd27: begin
                we = 31'b0000100000000000000000000000000;
            end
            5'd28: begin
                we = 31'b0001000000000000000000000000000;
            end
            5'd29: begin
                we = 31'b0010000000000000000000000000000;
            end
            5'd30: begin
                we = 31'b0100000000000000000000000000000;
            end
            5'd31: begin
                we = 31'b1000000000000000000000000000000;
            end
            default: begin
                we = 31'b0;
            end
         endcase
     end
endmodule
