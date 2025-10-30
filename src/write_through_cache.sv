`timescale 1us/100ns

module write_through_cache #(parameter INDEX_BITS = 5, // Index into cache
                             parameter CACHE_LINES = 2**INDEX_BITS, // Number of cache lines
                             parameter BLOCK_OFFSET = 6,
                             parameter DATA_LENGTH = 2**BLOCK_OFFSET, // Cache line length in bytes
                             parameter TAG_BITS = 32 - INDEX_BITS - BLOCK_OFFSET,
                             parameter STATUS_BITS = 1,
                             parameter LINE_LENGTH = TAG_BITS + DATA_LENGTH*8 + STATUS_BITS,
                             parameter WORD_SIZE = 32,
                             parameter WORD_BYTES = WORD_SIZE / 8,
                             parameter WORDS_PER_DATA_BLOCK = DATA_LENGTH / WORD_BYTES)
             (output [WORD_SIZE-1:0] data_out, 
              input  [WORD_SIZE-1:0] data_in, 
              input [31:0] addr,
              input wr,
              input re,
              input enable,
              output reg cache_miss_stall,

              output [WORD_SIZE-1:0] ext_data_out,
              input [WORD_SIZE-1:0] ext_data_in,
              output [31:0] ext_addr,
              output ext_wr,
              output ext_re,
              input ext_ack,

              // Clock and reset
              input clk, 
              input rst);

   

   wire [LINE_LENGTH-1:0] new_line;
   wire full_line_wr;
   wire hit;

   wire write_miss;
   wire read_miss;

   wire wr_ack;
   wire re_ack;

   assign write_miss = ~hit & wr & ~re;
   assign read_miss = ~hit & ~wr & re;

   cache_miss_controller #(
    .BYTES_PER_WORD(WORD_BYTES),
    .WORD_SIZE(WORD_SIZE),
    .INDEX_BITS(INDEX_BITS),
    .CACHE_LINES(CACHE_LINES),
    .BLOCK_OFFSET(BLOCK_OFFSET),
    .DATA_LENGTH(DATA_LENGTH),
    .TAG_BITS(TAG_BITS),
    .STATUS_BITS(STATUS_BITS),
    .LINE_LENGTH(LINE_LENGTH),
    .WORDS_PER_DATA_BLOCK(WORDS_PER_DATA_BLOCK))
   cont (.addr(addr),
         .data_from_cache(data_in),
         .data_to_cache(new_line),
         .ext_data_in(ext_data_in),
         .ext_data_out(ext_data_out),
         .ext_addr(ext_addr),
         .ext_ack(ext_ack),
         .ext_re(ext_re),
         .ext_wr(ext_wr),
         .wr_ack(wr_ack),
         .re_ack(re_ack),
         .re(read_miss),
         .wr(wr),
         .full_line_wr(full_line_wr),
         .enable(enable),
         .clk(clk),
         .rst(rst));

   cache #(
    .BYTES_PER_WORD(WORD_BYTES),
    .WORD_SIZE(WORD_SIZE),
    .INDEX_BITS(INDEX_BITS),
    .CACHE_LINES(CACHE_LINES),
    .BLOCK_OFFSET(BLOCK_OFFSET),
    .DATA_LENGTH(DATA_LENGTH),
    .TAG_BITS(TAG_BITS), 
    .STATUS_BITS(STATUS_BITS),
    .LINE_LENGTH(LINE_LENGTH)
   )
   cch(.data_out(data_out), 
       .data_in(data_in),
       .new_cache_line(new_line), 
       .addr(addr),
       .full_line_wr(full_line_wr),
       .wr(wr),
       .re(re),
       .enable(enable),
       .hit(hit),
       .clk(clk), 
       .rst(rst));

    always @(rst or enable or wr_ack or re_ack or read_miss or wr)
    begin
        if(rst | ~enable) // Reset or disabled defaults to no cache miss
            cache_miss_stall <= 1'b0;
        else begin
            if (cache_miss_stall) begin 
                if (wr_ack | re_ack) begin // If ACK signal recieved from cache controller, not in cache miss stall state anymore
                    cache_miss_stall <= 1'b0;
                end
                else begin
                    cache_miss_stall <= cache_miss_stall;
                end
            end
            else begin // If not in cache miss, check if a read miss happened or if a write through operation needs to happen
                cache_miss_stall <= read_miss | wr;
            end
        end
    end

endmodule