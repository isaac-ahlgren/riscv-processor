`timescale 1us/100ns

`define IDLE 2'b00
`define WRITE 2'b01
`define READ 2'b01
`define MISS 2'b11

module write_through_cache #(parameter INDEX_BITS = 5, // Index into cache
                             parameter CACHE_LINES = 2**INDEX_BITS, // Number of cache lines
                             parameter BLOCK_OFFSET = 6,
                             parameter DATA_LENGTH = 2**BLOCK_OFFSET, // Cache line length in bytes
                             parameter TAG_BITS = 32 - INDEX_BITS - BLOCK_OFFSET,
                             parameter STATUS_BITS = 1,
                             parameter LINE_LENGTH = TAG_BITS + DATA_LENGTH*8 + STATUS_BITS,
                             parameter WORD_SIZE = 32,
                             parameter WORD_BYTES = WORD_SIZE / 8)
             (output [WORD_SIZE-1:0] data_out, 
              input  [WORD_SIZE-1:0] data_in, 
              input [31:0] addr,
              input [WORD_BYTES:0] be,
              input wr,
              input re,
              input enable,
              output reg stall,

              output [WORD_SIZE-1:0] ext_data_out,
              input [WORD_SIZE-1:0] ext_data_in,
              output ext_wr,
              output ext_re,

              // Clock and reset
              input clk, 
              input rst);

   

   wire [LINE_LENGTH-1:0] line_in;
   wire [LINE_LENGTH-1:0] line_out;
   wire hit;

   wire write_hit;
   wire read_hit;

   assign write_hit = hit & wr & ~re;
   assign read_hit = hit & ~wr & re;


   cache #(
    .BYTES_PER_WORD(WORD_BYTES),
    .WORD_SIZE(WORD_SIZE),
    .INDEX_BITS(INDEX_BITS),
    .CACHE_LINES(CACHE_LINES),
    .BLOCK_OFFSET(LINE_LENGTH),
    .DATA_LENGTH(DATA_LENGTH),
    .TAG_BITS(TAG_BITS), 
    .STATUS_BITS(STATUS_BITS),
    .LINE_LENGTH(LINE_LENGTH)
   )
   cch(.data_out(line_out), 
       .data_in(line_in), 
       .new_cache_line(),
       .addr(addr),
       .full_line_wr(),
       .wr(wr),
       .re(re),
       .enable(enable),
       .hit(hit),
       .clk(clk), 
       .rst(rst));

endmodule