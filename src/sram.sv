
module sram
	#(parameter int
		ADDR_WIDTH = 16,
		BYTE_WIDTH = 8,
		BYTES = 4,
		WIDTH = BYTES * BYTE_WIDTH
)
( 
	input [ADDR_WIDTH-1:0] addr,
	input [BYTES-1:0] be,
	input [WIDTH-1:0] data, 
	input we, clk,
	output reg [WIDTH - 1:0] q
);
	localparam int WORDS = 1 << ADDR_WIDTH ;

	integer        mcd;
    integer        i;
	integer        j;

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
			if(be[0]) ram[addr][0] <= data[BYTE_WIDTH - 1:0];
			if(be[1]) ram[addr][1] <= data[2*BYTE_WIDTH - 1:BYTE_WIDTH];
			if(be[2]) ram[addr][2] <= data[3*BYTE_WIDTH - 1:2*BYTE_WIDTH];
			if(be[3]) ram[addr][3] <= data[4*BYTE_WIDTH - 1:3*BYTE_WIDTH];
	    end
		q <= ram[addr];

	    // synthesis translate_off
        mcd = $fopen("sram_dumpfile", "w");
        for (i=0; i <= WORDS*BYTES; i=i+1) begin
			for (j=0; j <= BYTES; j=j+1) begin
                $fdisplay(mcd,"%4h %2h", i, ram[j][i]);
			end
        end
        $fclose(mcd);
        // synthesis translate_on
	end
endmodule : sram
