
`timescale 1us/100ns

`include "proc.v"

module proc_tb();
    reg clk;
    reg rst;
    
    // Data from data main memory
    wire [31:0] dmem_data_out;
    // Data going into data main memory
    wire [31:0] dmem_data_in;
    // Address for the data main memory 
    wire [15:0] dmem_addr;
    // Write flag for data main memory
    wire dmem_wr;
    // Ready to read status for instruction main memory
    wire dmem_ready;
    // Data from instruction main memory
    wire [31:0] imem_data_out;
    // Data going into instruction main memory
    wire [31:0] imem_data_in;
    // Address for the instruction main memory 
    wire [15:0] imem_addr;
    // Write flag for instruction main memory
    wire imem_wr; 
    // Ready to read status for instruction main memory
    wire imem_ready;

    // Constants
    // Enable Caches
    wire enable;
    wire dmem_createdump;
    wire imem_createdump; 
    wire err;

    // Data Memory
    memory2c dmem (.data_out(dmem_data_out), .data_in(dmem_data_in), .addr(dmem_addr), .enable(enable), 
                   .wr(dmem_wr), .createdump(dmem_createdump), .clk(clk), .rst(rst));
    // Instruction Memory
    stallmem imem (.data_out(imem_data_out), .ready(imem_ready), .data_in(imem_data_in), .addr(imem_addr), .enable(enable), 
                   .wr(imem_wr), .createdump(instr_cache_createdump), .clk(clk), .rst(rst), .err(err));
    // Processor
    proc cpu (.dmem_data_out(dmem_data_out), .dmem_data_in(dmem_data_in), .dmem_addr(dmem_addr), .dmem_wr(dmem_wr), 
              .dmem_ready(dmem_ready), .imem_data_out(imem_data_out), .imem_data_in(imem_data_in), 
              .imem_addr(imem_addr), .imem_wr(imem_wr), .imem_ready(imem_ready), .clk(clk), .rst(rst));
    
    // Constants 
    assign enable = 1'b1;
    assign dmem_createdump = 1'b1;
    assign dmem_ready = 1'b1;
    assign imem_data_in = 32'b0;
    assign imem_createdump = 1'b0;
    assign imem_wr = 1'b0;
 
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