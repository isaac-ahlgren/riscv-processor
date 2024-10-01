`timescale 1us/100ns

module sram
	#(parameter int
		ADDR_WIDTH = 14,
		BYTE_WIDTH = 8,
		BYTES = 4,
		WIDTH = BYTES * BYTE_WIDTH
)
( 
	input [ADDR_WIDTH-1:0] addr,
	input [BYTES-1:0] be,
	input [WIDTH-1:0] data, 
	input we, re, clk, rst,
	output wire [WIDTH - 1:0] oq,
	output omem_ready
);
	localparam int WORDS = 1 << ADDR_WIDTH ;

	integer        mcd;
    integer        i;
	integer        j;

	// use a multi-dimensional packed array to model individual bytes within the word
	logic [BYTES-1:0][BYTE_WIDTH-1:0] ram[0:WORDS-1];

    reg [WIDTH - 1:0] q;
	reg [1:0] state;
	reg [1:0] next_state;
	reg mem_ready;


	initial 
	begin : INIT
		integer i;
		for(i = 0; i < 2**ADDR_WIDTH; i = i + 1)
			ram[i] = {WIDTH{1'b1}};
		$readmemh("../test_programs/blinky.hex", ram);
	end 

    assign oq = q & {WIDTH{re}};
	assign omem_ready = mem_ready;

    // State Machine to deal with 2 cycle reads
    always @(posedge clk)
    begin
        if(rst) begin
            state <= 2'b00;
		end
        else begin
            state <= next_state;
		end
    end

    always_comb
	begin
		case (state)
			2'b01:
			    if (re) begin
			        next_state <= 2'b10;
					mem_ready <= 1'b0;
				end
				else begin
					next_state <= 2'b01;
					mem_ready <= 1'b1;
				end
			2'b10: begin
			    next_state <= 2'b01;
				mem_ready <= 1'b1;
			end
			default: begin
			    next_state <= 2'b01;
				mem_ready <= 1'b0;
			end 
		endcase
	end

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



	    // synthesis translate_off
        mcd = $fopen("sram_dumpfile", "w");
        for (i=0; i < WORDS*BYTES; i=i+1) begin
			for (j=0; j < BYTES; j=j+1) begin
                $fdisplay(mcd,"%4h %2h", i*BYTES + j, ram[i][j]);
			end
        end
        $fclose(mcd);
        // synthesis translate_on
	end
endmodule : sram
