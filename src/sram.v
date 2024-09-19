
`define SRAM_SIZE 65536
`define DATA_SIZE 32
module sram (output reg [`DATA_SIZE-1:0] data_out, 
             input [`DATA_SIZE-1:0] data_in, 
             input [15:0] addr, 
             input enable, 
             input wr, 
             input clk, 
             input rst);
             
   wire                   in_bounds;

   reg [7:0]      mem [0:`SRAM_SIZE-1];
   reg [31:0]     data;

   integer        mcd;
   integer        i;

   assign         data_out = data;

   assign in_bounds = addr < (`SRAM_SIZE - 4);

   initial begin
      for (i=0; i<=65535; i=i+1) begin
         mem[i] = 8'd0;
      end
      $readmemh("../test_programs/blinky.hex", mem);
   end

   always @(*) begin
      if (enable & in_bounds) begin
         data <= {mem[addr+3],mem[addr+2],mem[addr+1],mem[addr]};
      end
      else begin
         data <= 32'b0;
      end
   end

   always @(posedge clk) begin

      if (enable & wr & in_bounds) begin
	        mem[addr+3] <= data_in[31:24];  // The actual write
	        mem[addr+2] <= data_in[23:16];  // The actual write
	        mem[addr+1] <= data_in[15:8];   // The actual write
	        mem[addr+0] <= data_in[7:0];    // The actual write
      end
      // synthesis translate_off
      mcd = $fopen("dumpfile", "w");
      for (i=0; i <= `SRAM_SIZE; i=i+1) begin
         $fdisplay(mcd,"%4h %2h", i, mem[i]);
      end
      $fclose(mcd);
      // synthesis translate_on
   end


endmodule
