
`timescale 1us/100ns

module proc_tb();
    reg clk;
    reg rst;
    
    // Data from data main memory
    wire [31:0] data_out;
    // Data going into data main memory
    wire [31:0] data_in;
    // Address for the data main memory 
    wire [31:0] addr;
    // Write flag for data main memory
    wire mem_wr;
    // Read flag
    wire mem_re;
    // Ready to read status for instruction main memory
    wire mem_ready;

    // input and output ports
    wire [12:0] dram_addr;
    wire [1:0] dram_ba;
    wire dram_cas_n;
    wire dram_cke;
    wire dram_clk;
    wire dram_cs_n;
    wire [15:0] dram_dq;
    wire dram_ldqm;
    wire dram_ras_n;
    wire dram_udqm;
    wire dram_we_n;
    wire [1:0] key;
    wire [9:0] ledr;
    wire [3:0] vga_b;
    wire [3:0] vga_g;
    wire vga_hs;
    wire [3:0] vga_r;
    wire vga_vs;
    wire [35:0]	gpio;


    // I NEED TO FIX THE INPUTS AND OUTPUTS TO THIS SIMULATION MODULE
    sdram_model sdram (.in_CLK(clk),
                       .in_CS,(dram_cs_n), // CHIP SELECT
                       .in_write_en(dram_we_n),
                       .in_CAS(dram_cs_n), //COLUMN ADRESS STROBE
                       .in_RAS(dram_ras_n), //ROW ADRESS STROBE
input[1:0]  in_bank_select,     // BANK SELECTION BITS
input[13:0] in_sdram_addr,      
input[31:0] in_sdram_write_data,

output reg [31:0] out_sdram_read_data 
// SDRAM MODEL INTERFACE END
);

   risc_de10 board (.ADC_CLK_10(clk),
	                .MAX10_CLK1_50(clk),
	                .MAX10_CLK2_50(clk),
	                .DRAM_ADDR(dram_addr),
	                .DRAM_BA(dram_ba),
                    .DRAM_CAS_N(dram_cas_n),
                    .DRAM_CKE(dram_cke),
                    .DRAM_CLK(dram_clk),
                    .DRAM_CS_N(dram_cs_n),
                    .DRAM_DQ(dram_dq),
                    .DRAM_LDQM(dram_ldqm),
                    .DRAM_RAS_N(dram_ras_n),
                    .DRAM_UDQM(dram_udqm),
	     		    .DRAM_WE_N(dram_we_n),
                    .KEY(key),
                    .LEDR(ledr),
                    .VGA_B(vga_b),
                    .VGA_G(vga_g),
                    .VGA_HS(vga_hs),
                    .VGA_R(vga_r),
                    .VGA_VS(vga_vs),
	                .GPIO(gpio)
    )

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 0;
	
	// reset logic  
        #2;
        rst = 1;
        #10;
        rst = 0;
          
	#50000;
	$finish;
    end

endmodule