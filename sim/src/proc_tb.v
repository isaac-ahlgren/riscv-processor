
`timescale 1us/100ns

module proc_tb();
    reg clk;

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
    reg [1:0] key;
    wire [9:0] ledr;
    wire [3:0] vga_b;
    wire [3:0] vga_g;
    wire vga_hs;
    wire [3:0] vga_r;
    wire vga_vs;
    wire [35:0]	gpio;


    sdram_model sdram (.in_CLK(clk),
                       .in_CS(dram_cs_n),           // CHIP SELECT
                       .in_write_en(dram_we_n),
                       .in_CAS(dram_cs_n),           //COLUMN ADRESS STROBE
                       .in_RAS(dram_ras_n),          //ROW ADRESS STROBE
                       .in_bank_select(dram_ba),     // BANK SELECTION BITS
                       .in_sdram_addr(dram_addr),      
                       .dram_ldqm(dram_ldqm),
                       .dram_udqm(dram_udqm),
                       .dq(dram_dq)); 

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
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        key = 2'b11;
	
	// reset logic  
        #2;
        key = 2'b00;
        #10;
        key = 2'b11;
          
	#50000;
	$finish;
    end

endmodule