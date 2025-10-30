`timescale 1us/100ns

module pipeline_latch (
                        output q, 
                        input d, 
                        input stall, 
                        input clk, 
                        input rst);

    reg            state;

    assign #(1) q = state;

    always @(posedge clk) begin
      state = rst? 0 : (stall ? q : d);
    end

endmodule
