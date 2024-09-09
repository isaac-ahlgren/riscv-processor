
`define PERIPH_REG_NUM 2
module de10_peripherals(
    input [31:0] addr,
    input wr, 
    input re,
    input [31:0] idata,
    output [31:0] odata,
    input clk, 
    input rst,
    output [9:0] LEDR,
    inout [35:0] GPIO

);
    wire [9:0] tag;
    wire {PERIPH_REG_NUM-1:0} we;

    assign tag = addr[31:22];

    reg_dflop gpio  [31:0](.q(), .d(idata), .we(we[0]),  .clk(clk), .rst(rst));

    always @ (*) begin
         case({tag})
             10'd1: begin
                we <= `PERIPH_REG_NUM'b01;
                odata <=
             end
             10'd2: begin
                we <= `PERIPH_REG_NUM'b10;
             end
             default: begin
                we <= `PERIPH_REG_NUM'00
             end
         endcase
    end

endmodule