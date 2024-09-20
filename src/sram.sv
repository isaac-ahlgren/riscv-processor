
module sram
	#(parameter int
		ADDR_WIDTH = 15,
		BYTE_WIDTH = 8,
		BYTES = 4,
		WIDTH = BYTES * BYTE_WIDTH
)
( 
	input [ADDR_WIDTH-1:0] addr,
	input [BYTES-1:0] be,
	input [BYTE_WIDTH-1:0] data, 
	input we, clk,
	output reg [WIDTH - 1:0] q
);
	localparam int WORDS = 1 << ADDR_WIDTH ;

	// use a multi-dimensional packed array to model individual bytes within the word
	logic [BYTES-1:0][BYTE_WIDTH-1:0] ram[0:WORDS-1];

	initial 
	begin : INIT
		integer i;
		for(i = 0; i < 2**ADDR_WIDTH; i = i + 1)
			ram[i] = {WIDTH{1'b1}};
		$readmemh("../test_programs/blinky.hex", ram);
	end 

	always_ff@(posedge clk)
	begin
		if(we) begin
		// edit this code if using other than four bytes per word
			if(be[0]) ram[addr][0] <= data;
			if(be[1]) ram[addr][1] <= data;
			if(be[2]) ram[addr][2] <= data;
			if(be[3]) ram[addr][3] <= data;
	end
		q <= ram[addr];

	    // synthesis translate_off
        mcd = $fopen("dumpfile", "w");
        for (i=0; i <= `SRAM_SIZE; i=i+1) begin
            $fdisplay(mcd,"%4h %2h", i, mem[i]);
        end
        $fclose(mcd);
        // synthesis translate_on
	end
endmodule : sram
