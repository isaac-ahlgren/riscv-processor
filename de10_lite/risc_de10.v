
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module risc_de10(

	//////////// CLOCK //////////
	input 		          		ADC_CLK_10,
	input 		          		MAX10_CLK1_50,
	input 		          		MAX10_CLK2_50,

	//////////// SDRAM //////////
	output		    [12:0]		DRAM_ADDR,
	output		     [1:0]		DRAM_BA,
	output		          		DRAM_CAS_N,
	output		          		DRAM_CKE,
	output		          		DRAM_CLK,
	output		          		DRAM_CS_N,
	inout 		    [15:0]		DRAM_DQ,
	output		          		DRAM_LDQM,
	output		          		DRAM_RAS_N,
	output		          		DRAM_UDQM,
	output		          		DRAM_WE_N,

	//////////// KEY //////////
	input 		     [1:0]		KEY,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// VGA //////////
	output		     [3:0]		VGA_B,
	output		     [3:0]		VGA_G,
	output		          		VGA_HS,
	output		     [3:0]		VGA_R,
	output		          		VGA_VS,

	//////////// GPIO, GPIO connect to GPIO Default //////////
	inout 		    [35:0]		GPIO
);



//=======================================================
//  REG/WIRE declarations
//=======================================================
    wire clk;
    wire rst;
    
	// Data from main memory from processor
    wire [31:0] data_out;
    // Data going directly into main memory
    wire [31:0] data_in;
    // Address going into the main memory
    wire [31:0] addr;
    // Write flag going into main memory
    wire mem_wr;
    // Read flag for data main memory
	wire mem_re;
    // Ready to read status for instruction main memory
    wire mem_ready;
	wire write_finished;
	wire read_finished;
    wire in_use;



//=======================================================
//  Structural coding
//=======================================================
    assign mem_ready = ~in_use;
    assign rst = KEY[0] | KEY[1];
	assign clk = MAX10_CLK1_50;

   // Processor
    proc cpu (.data_out(data_out), .data_in(data_in), .addr(addr), .mem_wr(mem_wr), .mem_re(mem_re), .mem_ready(mem_ready), 
              .clk(clk), .rst(rst));

	sdram_controller sdram_controller(
	    .iclk(clk),
        .ireset(rst),
		.oin_use(in_use),
    
        .iwrite_req(mem_wr),
        .iwrite_address(addr),
        .iwrite_data(data_in),
        .owrite_ack(write_finished),
    
        .iread_req(mem_re & 1'b1), // Always requesting read because instructions are needed and there is no cache yet
        .iread_address(addr),
        .oread_data(data_out),
        .oread_ack(read_finished),
    
	    //////////// SDRAM //////////
	    .DRAM_ADDR(DRAM_ADDR),
        .DRAM_BA(DRAM_BA),
        .DRAM_CAS_N(DRAM_CAS_N),
        .DRAM_CKE(DRAM_CKE),
        .DRAM_CLK(DRAM_CLK),
        .DRAM_CS_N(DRAM_CS_N),
        .DRAM_DQ(DRAM_DQ),
        .DRAM_LDQM(DRAM_LDQM),
        .DRAM_RAS_N(DRAM_RAS_N),
        .DRAM_UDQM(DRAM_UDQM),
        .DRAM_WE_N(DRAM_WE_N)
);

endmodule
