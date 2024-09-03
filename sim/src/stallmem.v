/////////////////////////////////////
//
// Memory -- stalling single cycle version
//
// written for CS/ECE 552, Spring '06
// Andy Phelps, 25 Jan 2006
//
// Karu
// Added reading seed from command line args
// all mem is intialized to zero first
// 
// Tony
// Stalls based on lfsr
// 
// This is a byte-addressable,
// 16-bit wide, 64K-byte memory that allows aligned accesses only.
//
// This module produces a "ready" signal;
// if "ready" is not asserted, the read
// or write did not take place.
//
// Reads happen combinationally with zero delay in cycles that ready is high.
// Writes occur on rising clock edge in cycles that ready is high.
// Concurrent read and write not allowed.
//
// On reset, memory loads from file "loadfile_all.img".
// (You may change the name of the file in
// the $readmemh statement below.)
// File format:
//     @0
//     <hex data 0>
//     <hex data 1>
//     ...etc
//
// If input "createdump" is true on rising clock,
// contents of memory will be dumped to
// file "dumpfile", from location 0 up through
// the highest location modified by a write.
//
//
//////////////////////////////////////

module stallmem (data_out, ready, data_in, addr, enable, wr, createdump, clk, rst, err);

   output  [31:0] data_out;
   output         ready;
   input [31:0]   data_in;
   input [15:0]   addr;
   input          enable;
   input          wr;
   input          createdump;
   input          clk;
   input          rst;
   output         err;

   wire [31:0]    data_out;

   reg [7:0]      mem [0:65535];
   reg            loaded;
   reg [16:0]     largest;
   reg [31:0]     rand_pat;

   integer        mcd;
   integer        i;

   assign         ready = enable & rand_pat[0];
   assign         err = ready & addr[0]; //word aligned; odd address is invalid
   assign         data_out = (enable & (~wr))? {mem[addr+3],mem[addr+2],mem[addr+1],mem[addr]}: 0;
   integer        seed;
   
   initial begin
      loaded = 0;
      largest = 0;
//      rand_pat = 32'b01010010011000101001111000001010;
      seed = 0;
      $display("Using seed %d", seed);
      rand_pat = $random(seed);
      $display("rand_pat=%08x %32b", rand_pat, rand_pat);
      // initialize memories to 0 first
      for (i=0; i<=65535; i=i+1) begin
         mem[i] = 8'd0;
      end
         
   end

   always @(posedge clk) begin
      if (rst) begin
         if (!loaded) begin
            $readmemh("../../test_programs/risc_test_verilog.txt", mem);
            loaded = 1;
         end
      end
      else begin
         if (ready & wr & ~err) begin
	        mem[addr+3] = data_in[31:24];  // The actual write
	        mem[addr+2] = data_in[23:16];  // The actual write
	        mem[addr+1] = data_in[15:8];   // The actual write
	        mem[addr+0] = data_in[7:0];    // The actual write
            if ({1'b0, addr} > largest) largest = addr;  // avoid negative numbers
         end
         if (createdump) begin
            mcd = $fopen("dumpfile");
            for (i=0; i<=largest; i=i+1) begin
               $fdisplay(mcd,"%4h %4h", i, mem[i]);
            end
            $fclose(mcd);
         end
		 //LFSR with taps at 31,21,1,0
         rand_pat = (rand_pat >> 1) | ( (rand_pat[0]^rand_pat[1]^rand_pat[21]^rand_pat[31]) << 31);
      end
   end


endmodule
// DUMMY LINE FOR REV CONTROL :0:

