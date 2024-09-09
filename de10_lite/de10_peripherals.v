
`define PERIPH_REG_NUM 2
module de10_peripherals(
    input [31:0] addr,
    input wr, 
    input [31:0] idata,
    output [31:0] odata,
    input clk, 
    input rst,
    output [9:0] LEDR,
    inout [35:0] GPIO

);
    wire [9:0] tag;
    wire [31:0] qn [`PERIPH_REG_NUM-1:0];
    wire {`PERIPH_REG_NUM-1:0} we;

    assign tag = addr[31:22];

    reg_dflop gpio1 [31:0] (.q(qn[0]), .d(idata), .we(we[0]),  .clk(clk), .rst(rst));
    reg_dflop gpio1 [31:0] (.q(qn[1]), .d(idata), .we(we[1]),  .clk(clk), .rst(rst));

    assign LEDR = qn[0][9:0]
    assign GPIO = {qn[1][13:0], qn[0][31:10]}

    always @ (*) begin
         case({tag})
             10'd1: begin
                odata <= qn[0];
             end
             10'd2: begin
                odata <= qn[1];
             end
             default: begin
                odata <= 32'b0;
             end
         endcase

         case({tag} & {`REG_BITS{wr}})
             10'd1: begin
                we <= `PERIPH_REG_NUM'b01;
             end
             10'd2: begin
                we <= `PERIPH_REG_NUM'b10;
             end
             default: begin
                we <= `PERIPH_REG_NUM'b00;
             end
         endcase
    end

endmodule