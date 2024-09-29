`timescale 1us/100ns

module sdram_controller(
    `include "sdram_controller.h"

	input 		          		iclk,
    input 		          		ireset,
    output                      omem_ready,
    
    input                       iwrite_req,
    input           [21:0]      iwrite_address,
    input          [`DATA_BLOCK_SIZE-1:0]      iwrite_data,
    output                      owrite_ack,
    
    input                       iread_req,
    input           [21:0]      iread_address,
    output         [`DATA_BLOCK_SIZE-1:0]      oread_data,
    output                      oread_ack,
    
	//////////// SDRAM //////////
	output		    [12:0]		DRAM_ADDR,
	output		     [1:0]		DRAM_BA,
	output		          		DRAM_CAS_N,
	output		          		DRAM_CKE,
	output		          		DRAM_CLK,
	output		          		DRAM_CS_N,
	inout 		    [`DB_WIDTH-1:0]		DRAM_DQ,
	output		          		DRAM_LDQM,
	output		          		DRAM_RAS_N,
	output		          		DRAM_UDQM,
	output		          		DRAM_WE_N
);

//=======================================================
//  REG/WIRE declarations
//=======================================================
reg      [8:0]  state       = `INIT1;
reg      [8:0]  next_state  = `INIT1;
reg      [2:0]  mul_state   = 3'b001;

reg             mem_ready   = 1'b1;
reg             read_ack    = 1'b0;
reg             write_ack   = 1'b0;

//SDRAM INITLIZE MODULE
reg             init_ireq   = 1'b0;
wire            init_ienb;
wire            init_fin;

//SDRAM WRITE MODULE
reg             write_ireq  = 1'b0;
wire            write_ienb;
wire    [12:0]  write_irow;
wire     [9:0]  write_icolumn;
wire     [1:0]  write_ibank;
wire            write_fin;

//SDRAM READ MODULE
reg             read_ireq   = 1'b0;
wire            read_ienb;
wire    [12:0]  read_irow;
wire     [9:0]  read_icolumn;
wire     [1:0]  read_ibank;
wire            read_fin;


//=======================================================
//  Structural coding
//=======================================================
assign {write_ibank, write_irow, write_icolumn} = {iwrite_address, 3'b0};
assign {read_ibank, read_irow, read_icolumn}    = {iread_address, 3'b0};

assign omem_ready                               = mem_ready;
assign owrite_ack                               = write_ack;
assign oread_ack                                = read_ack;

assign {read_ienb, write_ienb, init_ienb}       = mul_state;

always @(posedge iclk)
begin
    if(ireset == 1'b1)
        state <= #1 `INIT1;
    else
        state <= #1 next_state;
end

always @(state or init_fin or iwrite_req or iread_req or write_fin or read_fin)
begin
    case(state)
        //Init States
        `INIT1:
            next_state      <= `INIT2;
        `INIT2:
            if(init_fin)
                next_state  <= `IDLE_SC;
            else
                next_state  <= `INIT2;
                
        //Idle State
        `IDLE_SC:
            if(iwrite_req)
                next_state  <= `WRITE1;
            else if(iread_req)
                next_state  <= `READ1;
            else
                next_state  <= `IDLE_SC;
        //Write States
        `WRITE1:
            next_state      <= `WRITE2;    
        `WRITE2:
            if(write_fin)
                next_state  <= `WRITE3;
            else
                next_state  <= `WRITE2;
        `WRITE3:
            next_state      <= `IDLE_SC;
            
        //Read States        `
        `READ1:
            next_state      <= `READ2;
        `READ2:
            if(read_fin)
                next_state  <= `READ3;
            else
                next_state  <= `READ2;
        `READ3:
            next_state      <= `IDLE_SC;
        default:
            next_state      <= `INIT1;
    endcase
end

always @(state)
begin
    case(state)
        //Init States
        `INIT1:
        begin            
            init_ireq       <= 1'b1;
            write_ireq      <= 1'b0;
            read_ireq       <= 1'b0;
            
            mem_ready       <= 1'b0;
            write_ack       <= 1'b0;
            read_ack        <= 1'b0;
            
            mul_state       <= 3'b001;
        end
        `INIT2:
        begin            
            init_ireq       <= 1'b0;
            write_ireq      <= 1'b0;
            read_ireq       <= 1'b0;
            
            mem_ready       <= 1'b0;
            write_ack       <= 1'b0;
            read_ack        <= 1'b0;
            
            mul_state       <= 3'b001;
        end
        
        //Idle State
        `IDLE_SC:
        begin    
            init_ireq       <= 1'b0;
            write_ireq      <= 1'b0;
            read_ireq       <= 1'b0;
            
            mem_ready       <= 1'b1;
            write_ack       <= 1'b0;
            read_ack        <= 1'b0;
            
            mul_state       <= 3'b001;
        end
        
        //Write States
        `WRITE1:
        begin            
            init_ireq       <= 1'b0;
            write_ireq      <= 1'b1;
            read_ireq       <= 1'b0;
            
            mem_ready       <= 1'b0;
            write_ack       <= 1'b0;
            read_ack        <= 1'b0;
            
            mul_state       <= 3'b010;
        end
        
        `WRITE2:
        begin            
            init_ireq       <= 1'b0;
            write_ireq      <= 1'b0;
            read_ireq       <= 1'b0;
            
            mem_ready       <= 1'b0;
            write_ack       <= 1'b0;
            read_ack        <= 1'b0;
            
            mul_state       <= 3'b010;
        end
        `WRITE3:
        begin            
            init_ireq       <= 1'b0;
            write_ireq      <= 1'b0;
            read_ireq       <= 1'b0;
            
            mem_ready       <= 1'b0;
            write_ack       <= 1'b1;
            read_ack        <= 1'b0;
            
            mul_state       <= 3'b010;
        end
        
        //Read States
        `READ1:
        begin            
            init_ireq       <= 1'b0;
            write_ireq      <= 1'b0;
            read_ireq       <= 1'b1;
            
            mem_ready       <= 1'b0;
            write_ack       <= 1'b0;
            read_ack        <= 1'b0;
            
            mul_state       <= 3'b100;
        end
        `READ2:
        begin            
            init_ireq       <= 1'b0;
            write_ireq      <= 1'b0;
            read_ireq       <= 1'b0;
            
            mem_ready       <= 1'b1;
            write_ack       <= 1'b0;
            read_ack        <= 1'b0;
            
            mul_state       <= 3'b100;
        end
        `READ3:
        begin            
            init_ireq       <= 1'b0;
            write_ireq      <= 1'b0;
            read_ireq       <= 1'b0;
            
            mem_ready       <= 1'b0;
            write_ack       <= 1'b0;
            read_ack        <= 1'b1;
            
            mul_state       <= 3'b100;
        end
    endcase
end

sdram_initalize sdram_init (
    .iclk(iclk),
    .ireset(ireset),
    
    .ireq(init_ireq),
    .ienb(init_ienb),
    
    .ofin(init_fin),
    
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

sdram_write sdram_write (
    .iclk(iclk),
    .ireset(ireset),
    
    .ireq(write_ireq),
    .ienb(write_ienb),
    
    .irow(write_irow),
    .icolumn(write_icolumn),
    .ibank(write_ibank),
    .idata(iwrite_data),
    .ofin(write_fin),
    
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

sdram_read sdram_read (
    .iclk(iclk),
    .ireset(ireset),
    
    .ireq(read_ireq),
    .ienb(read_ienb),
    
    .irow(read_irow),
    .icolumn(read_icolumn),
    .ibank(read_ibank),
    .odata(oread_data),
    .ofin(read_fin),
    
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
