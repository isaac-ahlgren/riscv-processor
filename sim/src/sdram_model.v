
`define DATA_SIZE 16
module sdram_model
(
// SDRAM MODEL INTERFACE
input       in_CLK,
input       in_CS,              // CHIP SELECT
input       in_write_en,
input       in_CAS,             //COLUMN ADRESS STROBE
input       in_RAS,             //ROW ADRESS STROBE
input[1:0]  in_bank_select,     // BANK SELECTION BITS
input[12:0] in_sdram_addr,      
input dram_ldqm,
input dram_udqm,
inout reg [15:0] dq
// SDRAM MODEL INTERFACE END
);

	parameter DATA   = `DATA_SIZE,
			  ROW    = 16384,
			  COLUMN = 512;
			
	wire ACT,
		 READ_CAS,
		 WRITE_CAS,
		 NOP,
		 WRITE_READY;
 
	
	reg [13:0]registered_row     = 14'b0;
	reg [8:0]registered_column   = 9'b0;
	reg [1:0]registered_bank_sel = 2'b0;
	reg [1:0]nop_counter	     = 2'b0;
	reg registered_write_cas     = 1'b0, registered_read_cas = 1'b0;
		
	assign ACT         = ~in_CS && ~in_RAS && in_CAS && in_write_en;
	assign READ_CAS    = ~in_CS && in_RAS && ~in_CAS && in_write_en;
	assign WRITE_CAS   = ~in_CS && in_RAS && ~in_CAS && ~in_write_en;
	assign NOP         = ~in_CS && in_RAS && in_CAS && in_write_en;
	assign WRITE_READY = (nop_counter == 2 && NOP && registered_write_cas)? 1'b1: 1'b0; 
	reg [DATA-1 : 0] bank0 [0 : ROW-1][0 : COLUMN-1];
	reg [DATA-1 : 0] bank1 [0 : ROW-1][0 : COLUMN-1];
	reg [DATA-1 : 0] bank2 [0 : ROW-1][0 : COLUMN-1];
	reg [DATA-1 : 0] bank3 [0 : ROW-1][0 : COLUMN-1];


    wire [`DATA_SIZE-1:0] idata;
	reg [`DATA_SIZE-1:0] odata;
	assign idata = in_write_en ?  `DATA_SIZE'b0 : dq;
	assign dq = odata;
	
	localparam BANK0 = 2'b00,
			   BANK1 = 2'b01,
			   BANK2 = 2'b10,
			   BANK3 = 2'b11;
	
	always @(posedge in_CLK)begin
		if(!in_CS)begin
			if(ACT) begin
				registered_row[13:0]     <= in_sdram_addr[13:0];
				registered_bank_sel[1:0] <= in_bank_select[1:0];
			end
			else if (READ_CAS || WRITE_CAS)begin
				registered_column[8:0]   <= in_sdram_addr[8:0];
				registered_bank_sel[1:0] <= in_bank_select[1:0];
				registered_write_cas     <= WRITE_CAS;
			end

            if(nop_counter == 3)begin
                nop_counter <= 2'b0;
            end
            else if(NOP)begin
                nop_counter <= nop_counter + 1;    
            end	
		end
	end

    always @(*) begin
		if(WRITE_READY)begin

			case(registered_bank_sel)
		
				BANK0:begin
					bank0[registered_row][registered_column] = idata;
				end
		
				BANK1:begin
					bank1[registered_row][registered_column] = idata;
				end
		
				BANK2:begin
					bank2[registered_row][registered_column] = idata;
				end
		
				BANK3:begin
					bank3[registered_row][registered_column] = idata;
				end
		
			endcase	
		end
		else if(in_write_en)begin
		
			case(registered_bank_sel)
		
				BANK0:begin
					odata = bank0[registered_row][registered_column];
				end
		
				BANK1:begin
					odata = bank1[registered_row][registered_column];
				end
		
				BANK2:begin
					odata = bank2[registered_row][registered_column];
				end
		
				BANK3:begin
					odata = bank3[registered_row][registered_column];
				end
		
			endcase
		end	
	end

endmodule