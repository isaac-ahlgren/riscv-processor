// register D-flop
`timescale 1us/100ns

module reg_dflop (q, d, we, clk, rst);

    output         q;
    input          d;
    input          we;
    input          clk;
    input          rst;

    reg            state;

    assign #(1) q = state;
    assign dd = we ? d : q;

    always @(posedge clk) begin
      state = rst? 0 : dd;
    end

endmodule
