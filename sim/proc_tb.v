
`timescale 1us/100ns

module proc_tb();
    reg clk;
    reg rst;
    
    // Data from data main memory
    wire [31:0] data_out;
    // Data going into data main memory
    wire [31:0] data_in;
    // Address for the data main memory 
    wire [31:0] addr;
    // Write flag for data main memory
    wire mem_wr;
    // Ready to read status for instruction main memory
    wire mem_ready;

    // Constants
    // Enable Caches
    wire enable;
    wire createdump;
    wire err;

    // Instruction Memory
    stallmem mem (.data_out(data_out), .ready(mem_ready), .data_in(data_in), .addr(addr), .enable(enable), 
                   .wr(mem_wr), .createdump(createdump), .clk(clk), .rst(rst), .err(err));
    // Processor
    proc cpu (.data_out(data_out), .data_in(data_in), .addr(addr), .mem_wr(mem_wr), .mem_ready(mem_ready), 
              .clk(clk), .rst(rst));
    
    // Constants 
    assign enable = 1'b1;
    assign createdump = 1'b1;
 
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