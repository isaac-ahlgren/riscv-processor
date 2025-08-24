`timescale 1us/100ns

module sram
	#(parameter int ADDR_WIDTH = 14,
	  parameter int BYTE_WIDTH = 8,
	  parameter int BYTES = 4,
	  parameter int WIDTH = BYTES * BYTE_WIDTH,
	  parameter INIT_PROGRAM = "./tests/hex/risc_test.hex"
	)
( 
	input [ADDR_WIDTH-1:0] addr,
	input [BYTES-1:0] be,
	input [WIDTH-1:0] data, 
	input we, re, clk, rst,
	output reg [WIDTH - 1:0] oq,
	output omem_ready
);
	localparam int WORDS = 1 << ADDR_WIDTH ;

	integer        mcd;
    integer        i;
	integer        j;

	// use a multi-dimensional packed array to model individual bytes within the word
	logic [BYTES-1:0][BYTE_WIDTH-1:0] ram[0:WORDS-1];

    reg rest;
	reg rest_state;
    reg [WIDTH - 1:0] q;

	wire mem_transaction;

	assign mem_transaction = we | re;

    // Initializing memory with initalization program
	initial 
	begin : INIT
		integer i;
		for(i = 0; i < 2**ADDR_WIDTH; i = i + 1)
			ram[i] = {WIDTH{1'b1}};
		$readmemh(INIT_PROGRAM, ram);
	end 
    

	// Memory Control Logic
	always @(posedge clk)
	begin
		if (rst) begin
            #(1) oq <= {WIDTH{1'b0}};           
		end
		else begin
			#(1) oq <= q & {WIDTH{re}};
		end
	end

	always @(posedge clk)
	begin
		if (rst) begin
			rest <= 1'b0;
		end
		else begin
			rest <= ~rest_state & mem_transaction;
		end
	end

    assign #(1) rest_state = rest;

	// Memory is ready to be read if there are not memory transactions happening or there is no transaction rest
	assign omem_ready = ~mem_transaction | ~rest;

    // Memory read/write logic
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
	end

    // synthesis translate_off
	always @(posedge clk)
	begin
        mcd = $fopen("sram_dumpfile", "w");
        for (i=0; i < WORDS*BYTES; i=i+1) begin
			for (j=0; j < BYTES; j=j+1) begin
                $fdisplay(mcd,"%4h %2h", i*BYTES + j, ram[i][j]);
			end
        end
        $fclose(mcd);
	end
	// synthesis translate_on
endmodule : sram
