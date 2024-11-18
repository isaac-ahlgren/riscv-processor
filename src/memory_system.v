`timescale 1us/100ns

`define IDLE    2'b00
`define IMEM_OP 2'b01
`define DMEM_OP 2'b10

module memory_system #(parameter WORD_SIZE = 32)
                       (output reg [WORD_SIZE-1:0] imem_data_out, 
                        output reg [WORD_SIZE-1:0] dmem_data_out, 
                        input [WORD_SIZE-1:0] data_out,
                        output imem_stall, 
                        output dmem_stall,
                        output stall,
                        output first_stage_stall,
                        output squash,
                        input mem_ready, 
                        input jump_taken,
                        input [31:0] imem_addr, 
                        input [31:0] dmem_addr, 
                        output reg [31:0] mem_addr, 
                        input en_mem_re,
                        input en_mem_wr,
                        output reg en_ext_mem_re,
                        output reg en_ext_mem_wr,
                        input data_hazard,
                        input control_hazard,
                        input clk,
                        input rst);

    wire imem_use;
    wire imem_use_delayed;

    wire imem_data_mask;
    wire dmem_data_mask;

    wire [31:0] save_slot;

    wire [WORD_SIZE-1:0] dmem_data;
    wire [WORD_SIZE-1:0] data_to_dmem_cache;
    wire [WORD_SIZE-1:0] data_from_dmem_cache;
    wire [31:0] dmem_ext_addr_cache;
    wire dmem_ext_re_cache;
    wire dmem_ext_wr_cache;
    reg dmem_ext_mem_ready;
    wire dmem_enable_cache;
    wire dmem_ready_cache;
    reg dmem_ready;
    wire dmem_re_en;
    wire dmem_wr_en;
    reg dmem_ext_re;
    reg dmem_ext_wr;
    reg dmem_ext_mem_op;

    wire [WORD_SIZE-1:0] imem_data;
    wire [WORD_SIZE-1:0] data_to_imem_cache;
    wire [WORD_SIZE-1:0] data_from_imem_cache;
    wire [31:0] imem_ext_addr_cache;
    wire imem_ext_re_cache;
    wire imem_ext_wr_cache;
    reg imem_ext_mem_ready;
    wire imem_enable_cache;
    wire imem_ready_cache;
    reg imem_ready;
    wire imem_re_en;
    wire imem_wr_en;
    reg imem_ext_re;
    reg imem_ext_wr;
    reg imem_ext_mem_op;

    wire full_imem_stall; 

    assign dmem_re_en = en_mem_re;
    assign dmem_wr_en = en_mem_wr;

    assign imem_re_en = 1'b1;
    assign imem_wr_en = 1'b0;

    assign full_imem_stall = imem_stall & ~dmem_ext_mem_op & jump_taken; // Full pipeline stall for the icache if there is not a miss in the dcache and jump is going to be taken
    assign imem_stall = ~imem_ready & ~control_hazard;
    assign dmem_stall = ~dmem_ready;
    assign stall = dmem_stall | full_imem_stall;
    assign first_stage_stall = stall | data_hazard | (imem_stall & control_hazard); 

    assign squash = data_hazard | control_hazard;

    write_through_cache imem_cache
             (.data_out(imem_data), 
              .data_in({WORD_SIZE{1'b0}}), 
              .addr(imem_addr),
              .wr(imem_wr_en),
              .re(imem_re_en),
              .enable(imem_enable_cache),
              .stall(imem_ready_cache),
              .ext_data_out(data_from_imem_cache),
              .ext_data_in(data_to_imem_cache),
              .ext_addr(imem_ext_addr_cache),
              .ext_wr(imem_ext_wr_cache),
              .ext_re(imem_ext_re_cache),
              .ext_ack(imem_ext_mem_ready),
              .clk(clk), 
              .rst(rst));

    write_through_cache dmem_cache
             (.data_out(dmem_data), 
              .data_in(data_out), 
              .addr(dmem_addr),
              .wr(dmem_wr_en),
              .re(dmem_re_en),
              .enable(dmem_enable_cache),
              .stall(dmem_ready_cache),
              .ext_data_out(data_from_dmem_cache),
              .ext_data_in(data_to_dmem_cache),
              .ext_addr(dmem_ext_addr_cache),
              .ext_wr(dmem_ext_wr_cache),
              .ext_re(dmem_ext_re_cache),
              .ext_ack(dmem_ext_mem_ready),
              .clk(clk), 
              .rst(clk));

    memory_map mm (
        .imem_addr(imem_addr),
        .dmem_addr(dmem_addr),
        .imem_cache_enable(imem_enable_cache),
        .dmem_cache_enable(dmem_enable_cache)
    );

    reg [1:0] state;
    reg [1:0] next_state;

    always @(posedge clk or posedge rst)
    begin
        if(rst)
            state <= #1 `IDLE;
        else
            state <= #1 next_state;
    end
    
     always @(state or dmem_ready or imem_ready) begin
        case(state)
            `IDLE:
                if(~imem_ready | ~dmem_ready) begin
                    if (~dmem_ready) begin
                        next_state   <= `DMEM_OP;
                    end
                    else begin
                        next_state   <= `IMEM_OP;
                    end
                end
                else begin
                    next_state   <= `IDLE;
                end
            `DMEM_OP:
                if (dmem_ready) begin
                    next_state <= `IDLE;
                end
                else begin
                    next_state       <= `DMEM_OP;
                end
            `IMEM_OP:
                if (imem_ready) begin
                    next_state <= `IDLE;
                end
                else begin
                    next_state <= `IMEM_OP;
                end
        endcase
     end

    always @(*)
    begin
        case(state)
            `IDLE:
            begin
                mem_addr <= 32'b0;
                en_ext_mem_re <= 1'b0;
                en_ext_mem_wr <= 1'b0;
                imem_ext_mem_ready <= 1'b1;
                dmem_ext_mem_ready <= 1'b1;
                imem_ext_mem_op <= 1'b0;
                dmem_ext_mem_op <= 1'b0;
            end
            `DMEM_OP:
            begin
                mem_addr <= dmem_addr;
                en_ext_mem_re <= dmem_ext_re;
                en_ext_mem_wr <= dmem_ext_wr;
                imem_ext_mem_ready <= 1'b0;
                dmem_ext_mem_ready <= mem_ready;
                imem_ext_mem_op <= 1'b0;
                dmem_ext_mem_op <= 1'b1;
            end
            `IMEM_OP:
            begin
                mem_addr <= imem_addr;
                en_ext_mem_re <= imem_ext_re;
                en_ext_mem_wr <= dmem_ext_wr;
                imem_ext_mem_ready <= mem_ready;
                dmem_ext_mem_ready <= 1'b0;
                imem_ext_mem_op <= 1'b1;
                dmem_ext_mem_op <= 1'b0;
            end
        endcase

        if (imem_enable_cache) begin
            imem_data_out <= imem_data;
            imem_ready <= imem_ready_cache;
            imem_ext_re <= imem_ext_re_cache;
            imem_ext_wr <= imem_ext_wr_cache;
        end
        else begin
            imem_data_out <= data_out & {32{mem_ready & (imem_re_en | imem_wr_en)}};
            imem_ready <= imem_ext_mem_ready;
            imem_ext_re <= imem_re_en;
            imem_ext_wr <= imem_wr_en;
        end

        if (dmem_enable_cache) begin
            dmem_data_out <= dmem_data;
            dmem_ready <= dmem_ready_cache;
            imem_ext_re <= imem_ext_re_cache;
            imem_ext_wr <= imem_ext_wr_cache;
        end
        else begin
            dmem_data_out <= data_out & {32{mem_ready & (dmem_re_en | dmem_wr_en)}};
            dmem_ready <= dmem_ext_mem_ready;
            dmem_ext_re <= dmem_re_en;
            dmem_ext_wr <= dmem_wr_en;
        end
    end
endmodule