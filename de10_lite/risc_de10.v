
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
    wire rst;
    // Data from data main memory
    wire [31:0] dmem_data_out;
    // Data going into data main memory
    wire [31:0] dmem_data_in;
    // Address for the data main memory 
    wire [15:0] dmem_addr;
    // Write flag for data main memory
    wire dmem_wr;
    // Ready to read status for instruction main memory
    wire dmem_ready;
    // Data from instruction main memory
    wire [31:0] imem_data_out;
    // Data going into instruction main memory
    wire [31:0] imem_data_in;
    // Address for the instruction main memory 
    wire [15:0] imem_addr;
    // Write flag for instruction main memory
    wire imem_wr; 
    // Ready to read status for instruction main memory
    wire imem_ready;



//=======================================================
//  Structural coding
//=======================================================
    assign rst = KEY[0] | KEY[1]

    proc cpu (.dmem_data_out(dmem_data_out), .dmem_data_in(dmem_data_in), .dmem_addr(dmem_addr), .dmem_wr(dmem_wr), 
              .dmem_ready(dmem_ready), .imem_data_out(imem_data_out), .imem_data_in(imem_data_in), 
              .imem_addr(imem_addr), .imem_wr(imem_wr), .imem_ready(imem_ready), .clk(MAX10_CLK1_50), .rst(rst));

	Sdram_Control u1 (	//	HOST Side
						.REF_CLK(MAX10_CLK1_50),
					    .RESET_N(rst),
						//	FIFO Write Side 
						.WR_DATA(writedata),
						.WR(write),
						.WR_ADDR(0),
						.WR_MAX_ADDR(25'h1ffffff),		//	
						.WR_LENGTH(9'h80),
						.WR_LOAD(!test_global_reset_n ),
						.WR_CLK(clk_test),
						//	FIFO Read Side 
						.RD_DATA(readdata),
				        .RD(read),
				        .RD_ADDR(0),			//	Read odd field and bypess blanking
						.RD_MAX_ADDR(25'h1ffffff),
						.RD_LENGTH(9'h80),
				        .RD_LOAD(!test_global_reset_n ),
						.RD_CLK(clk_test),
                        //	SDRAM Side
						.SA(DRAM_ADDR),
						.BA(DRAM_BA),
						.CS_N(DRAM_CS_N),
						.CKE(DRAM_CKE),
						.RAS_N(DRAM_RAS_N),
				        .CAS_N(DRAM_CAS_N),
				        .WE_N(DRAM_WE_N),
						.DQ(DRAM_DQ),
				        .DQM({DRAM_UDQM,DRAM_LDQM}),
						.SDR_CLK(DRAM_CLK)	);
endmodule
