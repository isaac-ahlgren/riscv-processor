`timescale 1us/100ns

module cache #(parameter BYTES_PER_WORD = 4,
               parameter WORD_SIZE = 32,
               parameter INDEX_BITS = 5, // Index into cache
               parameter CACHE_LINES = 2**INDEX_BITS, // Number of cache lines
               parameter BLOCK_OFFSET = 6,
               parameter DATA_LENGTH = 2**BLOCK_OFFSET, // Cache line length in bytes
               parameter TAG_BITS = 32 - INDEX_BITS - BLOCK_OFFSET,
               parameter STATUS_BITS = 1,
               parameter LINE_LENGTH = TAG_BITS + DATA_LENGTH*8 + STATUS_BITS,
               parameter WORDS_PER_DATA_BLOCK = DATA_LENGTH / BYTES_PER_WORD
            )
             (
              output reg [WORD_SIZE-1:0] data_out, 
              input  [WORD_SIZE-1:0] data_in,
              input [LINE_LENGTH-1:0] new_cache_line, 
              input [31:0] addr,
              input full_line_wr,
              input wr,
              input re,
              input enable,
              output hit,

              // Clock and reset
              input clk, 
              input rst);
   
    wire [TAG_BITS-1:0] tag;
    wire [INDEX_BITS-1:0] index;
    wire [BLOCK_OFFSET-3:0] offset;

    wire valid;
    wire [TAG_BITS-1:0] line_tag;

    reg [LINE_LENGTH-1:0]      mem [CACHE_LINES-1:0];
    
    assign index = addr[INDEX_BITS+BLOCK_OFFSET-1:BLOCK_OFFSET];
    assign tag = addr[31:INDEX_BITS+BLOCK_OFFSET];
    assign offset = addr[BLOCK_OFFSET-1:2];
    assign valid = mem[index][0];
    assign line_tag = mem[index][LINE_LENGTH-1:LINE_LENGTH-TAG_BITS];

    integer i;
    initial begin
       for (i = 0; i< CACHE_LINES; i=i+1) begin
          mem[i] = {LINE_LENGTH{1'b0}};
       end
    end

   assign hit = (valid == 1'b1) & (line_tag == tag);

   always @(*) begin
      if (rst | ~enable) begin
         data_out <= {WORD_SIZE{1'b0}};
      end
      else begin
         case (offset)
               4'd0: 
               begin
                  data_out <= mem[index][WORD_SIZE + STATUS_BITS : STATUS_BITS];
               end
               4'd1: 
               begin
                  data_out <= mem[index][2*WORD_SIZE + STATUS_BITS : WORD_SIZE + STATUS_BITS];
               end
               4'd2: 
               begin
                  data_out <= mem[index][3*WORD_SIZE + STATUS_BITS : 2*WORD_SIZE + STATUS_BITS];
               end
               4'd3: 
               begin
                  data_out <= mem[index][4*WORD_SIZE + STATUS_BITS : 3*WORD_SIZE + STATUS_BITS];
               end
               4'd4: 
               begin
                  data_out <= mem[index][5*WORD_SIZE + STATUS_BITS : 4*WORD_SIZE + STATUS_BITS];
               end
               4'd5: 
               begin
                  data_out <= mem[index][6*WORD_SIZE + STATUS_BITS : 5*WORD_SIZE + STATUS_BITS];
               end
               4'd6: 
               begin
                  data_out <= mem[index][7*WORD_SIZE + STATUS_BITS : 6*WORD_SIZE + STATUS_BITS];
               end
               4'd7: 
               begin
                  data_out <= mem[index][8*WORD_SIZE + STATUS_BITS : 7*WORD_SIZE + STATUS_BITS];
               end
               4'd8: 
               begin
                  data_out <= mem[index][9*WORD_SIZE + STATUS_BITS : 8*WORD_SIZE + STATUS_BITS];
               end
               4'd9: 
               begin
                  data_out <= mem[index][10*WORD_SIZE + STATUS_BITS : 9*WORD_SIZE + STATUS_BITS];
               end
               4'd10: 
               begin
                  data_out <= mem[index][11*WORD_SIZE + STATUS_BITS : 10*WORD_SIZE + STATUS_BITS];
               end
               4'd11: 
               begin
                  data_out <= mem[index][12*WORD_SIZE + STATUS_BITS : 11*WORD_SIZE + STATUS_BITS];
               end
               4'd12: 
               begin
                  data_out <= mem[index][13*WORD_SIZE + STATUS_BITS : 12*WORD_SIZE + STATUS_BITS];
               end
               4'd13: 
               begin
                  data_out <= mem[index][14*WORD_SIZE + STATUS_BITS : 13*WORD_SIZE + STATUS_BITS];
               end
               4'd14: 
               begin
                  data_out <= mem[index][15*WORD_SIZE + STATUS_BITS : 14*WORD_SIZE + STATUS_BITS];
               end
               4'd15: 
               begin
                  data_out <= mem[index][16*WORD_SIZE + STATUS_BITS : 15*WORD_SIZE + STATUS_BITS];
               end
         endcase
      end
   end

   always @(posedge clk or posedge rst) begin
      if (full_line_wr & enable) begin
         mem[index] <= new_cache_line;
      end

      if (hit & wr & ~re & enable) begin
            case (offset)
               4'd0: 
               begin
                  mem[index][WORD_SIZE + STATUS_BITS : STATUS_BITS] <= data_in;
               end
               4'd1: 
               begin
                  mem[index][2*WORD_SIZE + STATUS_BITS : WORD_SIZE + STATUS_BITS] <= data_in;
               end
               4'd2: 
               begin
                  mem[index][3*WORD_SIZE + STATUS_BITS : 2*WORD_SIZE + STATUS_BITS] <= data_in;
               end
               4'd3: 
               begin
                  mem[index][4*WORD_SIZE + STATUS_BITS : 3*WORD_SIZE + STATUS_BITS] <= data_in;
               end
               4'd4: 
               begin
                  mem[index][5*WORD_SIZE + STATUS_BITS : 4*WORD_SIZE + STATUS_BITS] <= data_in;
               end
               4'd5: 
               begin
                  mem[index][6*WORD_SIZE + STATUS_BITS : 5*WORD_SIZE + STATUS_BITS] <= data_in;
               end
               4'd6: 
               begin
                  mem[index][7*WORD_SIZE + STATUS_BITS : 6*WORD_SIZE + STATUS_BITS] <= data_in;
               end
               4'd7: 
               begin
                  mem[index][8*WORD_SIZE + STATUS_BITS : 7*WORD_SIZE + STATUS_BITS] <= data_in;
               end
               4'd8: 
               begin
                  mem[index][9*WORD_SIZE + STATUS_BITS : 8*WORD_SIZE + STATUS_BITS] <= data_in;
               end
               4'd9: 
               begin
                  mem[index][10*WORD_SIZE + STATUS_BITS : 9*WORD_SIZE + STATUS_BITS] <= data_in;
               end
               4'd10: 
               begin
                  mem[index][11*WORD_SIZE + STATUS_BITS : 10*WORD_SIZE + STATUS_BITS] <= data_in;
               end
               4'd11: 
               begin
                  mem[index][12*WORD_SIZE + STATUS_BITS : 11*WORD_SIZE + STATUS_BITS] <= data_in;
               end
               4'd12: 
               begin
                  mem[index][13*WORD_SIZE + STATUS_BITS : 12*WORD_SIZE + STATUS_BITS] <= data_in;
               end
               4'd13: 
               begin
                  mem[index][14*WORD_SIZE + STATUS_BITS : 13*WORD_SIZE + STATUS_BITS] <= data_in;
               end
               4'd14: 
               begin
                  mem[index][15*WORD_SIZE + STATUS_BITS : 14*WORD_SIZE + STATUS_BITS] <= data_in;
               end
               4'd15: 
               begin
                  mem[index][16*WORD_SIZE + STATUS_BITS : 15*WORD_SIZE + STATUS_BITS] <= data_in;
               end
            endcase
         end
   end
endmodule