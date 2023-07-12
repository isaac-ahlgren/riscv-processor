`timescale 1us/100ns

module latch (q, d, stall, clk, rst);

    output         q;
    input          d;
    input          stall;
    input          clk;
    input          rst;

    reg            state;

    assign #(1) q = state;
    assign dd = stall ? d : q;

    always @(posedge clk) begin
      state = rst? 0 : dd;
    end

endmodule
