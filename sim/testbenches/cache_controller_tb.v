`timescale 1us/100ns

module cache_controller_tb  #(parameter BYTES_PER_WORD = 4,
                              parameter WORD_SIZE = 32,
                              parameter INDEX_BITS = 5, // Index into cache
                              parameter CACHE_LINES = 2**INDEX_BITS, // Number of cache lines
                              parameter BLOCK_OFFSET = 6,
                              parameter DATA_LENGTH = 2**BLOCK_OFFSET, // Cache line length in bytes
                              parameter TAG_BITS = 32 - INDEX_BITS - BLOCK_OFFSET,
                              parameter STATUS_BITS = 1,
                              parameter LINE_LENGTH = TAG_BITS + DATA_LENGTH*8 + STATUS_BITS,
                              parameter WORDS_PER_DATA_BLOCK = DATA_LENGTH / BYTES_PER_WORD)();
    reg clk;
    reg rst;

    wire ready;
    wire err;

    wire stall;
    wire [WORD_SIZE-1:0] data_out;
    reg [WORD_SIZE-1:0] data_in;
    reg [31:0] addr;
    wire [31:0] ext_addr;
    wire [31:0] data_to_ext_mem;
    reg wr;
    reg re;
    wire [31:0] data_from_ext_mem;
    wire [31:0] addr_to_ext_mem;
    wire [LINE_LENGTH-1:0] data_to_cache;
    wire ext_re;
    wire ext_wr;
    wire wr_ack;
    wire re_ack;

    stallmem mem (.data_out(data_from_ext_mem), 
                  .ready(ready), 
                  .data_in(data_to_ext_mem), 
                  .addr(ext_addr[15:2]), 
                  .enable(1'b1), 
                  .wr(ext_wr), 
                  .createdump(1'b1), 
                  .clk(clk), 
                  .rst(rst), 
                  .err(err));

    write_through_cache #(.INDEX_BITS(INDEX_BITS),
                          .CACHE_LINES(CACHE_LINES),
                          .BLOCK_OFFSET(BLOCK_OFFSET),
                          .DATA_LENGTH(DATA_LENGTH),
                          .TAG_BITS(TAG_BITS),
                          .STATUS_BITS(STATUS_BITS),
                          .LINE_LENGTH(LINE_LENGTH),
                          .WORD_SIZE(WORD_SIZE),
                          .WORD_BYTES(BYTES_PER_WORD))
            cache (.data_out(data_out), 
              .data_in(data_in), 
              .addr(addr),
              .wr(wr),
              .re(re),
              .enable(enable),
              .stall(stall),
              .ext_data_out(data_to_ext_mem),
              .ext_data_in(data_from_ext_mem),
              .ext_addr(ext_addr),
              .ext_wr(ext_wr),
              .ext_re(ext_re),
              .ext_ack(ready),
              .clk(clk), 
              .rst(rst));

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 0;
        data_in = 32'b0;
        addr = 32'h0;
        wr = 1'b0;
        re = 1'b0;
	
	// reset logic  
        #2;
        rst = 1;
        #10;
        rst = 0;

        #10
        data_in = {32{1'b1}};
        addr = 32'hf0;
        wr = 1'b1;
        #10
        addr = 32'h1;
        wr = 1'b0;
        re = 1'b1;



          
	#50000;
	$finish;
    end

endmodule