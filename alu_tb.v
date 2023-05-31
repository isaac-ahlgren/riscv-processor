
`timescale 1us/100ns

`include "proc.v"

module alu_tb();
    reg clk;
    reg rst;

    proc cpu (.clk(clk), .rst(rst));
        
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 0;
	
	// reset logic  
        #2;
        rst = 1;
        #10;
        rst = 0;
          
	#50000;
	$finish;
    end

endmodule