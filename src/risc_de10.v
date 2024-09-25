
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
    wire en_sdram;
	wire en_peripherals;
	wire en_sram;
	wire [31:0] periph_data;
	wire [31:0] sdram_data;
	wire [31:0] sram_data;

//=======================================================
//  Structural coding
//=======================================================
    assign rst = ~(KEY[0] & KEY[1]);
	assign clk = MAX10_CLK1_50;

   // Processor
    proc cpu (.data_out(data_out), .data_in(data_in), .addr(addr), .omem_wr(mem_wr), .omem_re(mem_re), .mem_ready(mem_ready), 
              .clk(clk), .rst(rst));

	de10_bus_controller bus_controller (.addr(addr),
	                                    .sram_data(sram_data),
                                        .sdram_data(sdram_data),
										.peripheral_data(periph_data),
										.sram_ready(1'b1),
										.sdram_ready(~in_use),
										.peripheral_ready(1'b1),
										.oen_sram(en_sram),
										.oen_sdram(en_sdram), 
										.oen_peripherals(en_peripherals),
										.odata(data_out),
										.omem_ready(mem_ready));

    sram sr (.data(data_in), 
             .oq(sram_data),
			 .be(4'b1111),
             .addr(addr[15:0]), 
             .we(mem_wr & en_sram),
			 .re(mem_re & en_sram),
             .clk(clk));

    de10_peripherals periph (.addr(addr),
							 .wr(mem_wr & en_peripherals), 
							 .idata(data_in),
							 .odata(periph_data),
							 .clk(clk), 
							 .rst(rst),
							 .LEDR(LEDR),
							 .GPIO(GPIO)
                        );

	sdram_controller sdram_controller(
	    .iclk(clk),
        .ireset(rst),
		.oin_use(in_use),
    
        .iwrite_req(mem_wr & en_sdram),
        .iwrite_address(addr[21:0]),
        .iwrite_data(data_in),
        .owrite_ack(write_finished),
    
        .iread_req(mem_re & en_sdram),
        .iread_address(addr[21:0]),
        .oread_data(sdram_data),
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
