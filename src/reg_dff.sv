// register D-flop
`timescale 1us/100ns

module reg_dflop (q, d, we, clk, rst);

    output    wire q;
    input     wire d;
    input     wire we;
    input     wire clk;
    input     wire rst;

	 wire           dd;
	 
    reg            state;

    assign #(1) q = state;
    assign dd = we ? d : q;

    always @(posedge clk) begin
      state = rst? 0 : dd;
    end

endmodule
