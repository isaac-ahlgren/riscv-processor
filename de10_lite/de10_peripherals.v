
`define PERIPH_REG_NUM 2
`define ADDR_LEN 22
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
    wire [9:0] periph_addr;
    wire [31:0] qn [`PERIPH_REG_NUM-1:0];
    reg [`PERIPH_REG_NUM-1:0] we;
    reg [31:0] data;

    assign periph_addr = addr[21:0];
    assign LEDR = qn[0][9:0];
    assign GPIO = {qn[1][13:0], qn[0][31:10]};
    assign odata = data;

    reg_dflop gpio1 [31:0] (.q(qn[0]), .d(idata), .we(we[0]),  .clk(clk), .rst(rst));
    reg_dflop gpio2 [31:0] (.q(qn[1]), .d(idata), .we(we[1]),  .clk(clk), .rst(rst));

    always @ (*) begin
         case({periph_addr})
             22'd0: begin
                data <= qn[0];
             end
             22'd1: begin
                data <= qn[1];
             end
             default: begin
                data <= 32'b0;
             end
         endcase

         case({periph_addr} & {`ADDR_LEN{wr}})
             22'd0: begin
                we <= `PERIPH_REG_NUM'b01;
             end
             22'd1: begin
                we <= `PERIPH_REG_NUM'b10;
             end
             default: begin
                we <= `PERIPH_REG_NUM'b00;
             end
         endcase
    end

endmodule