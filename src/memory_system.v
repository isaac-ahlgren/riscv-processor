`timescale 1us/100ns

`define IMEM_OP 2'b01
`define DMEM_OP 2'b10

module memory_system #(parameter WORD_SIZE = 32)
                       (output reg [WORD_SIZE-1:0] imem_data_out, 
                        output reg [WORD_SIZE-1:0] dmem_data_out,
                        input [WORD_SIZE-1:0] dmem_data_in,
                        input [WORD_SIZE-1:0] data_out,
                        output reg [WORD_SIZE-1:0] data_in,
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

    wire dmem_op;

    wire [WORD_SIZE-1:0] dmem_data;
    reg [31:0] dmem_addr_out;
    wire [WORD_SIZE-1:0] data_from_dmem_cache;
    wire [31:0] dmem_ext_addr_cache;
    wire dmem_ext_re_cache;
    wire dmem_ext_wr_cache;
    reg dmem_ext_mem_ready;
    wire dmem_enable_cache;
    wire dmem_cache_miss_stall;
    reg dmem_ready;
    wire dmem_re_en;
    wire dmem_wr_en;
    reg dmem_ext_re;
    reg dmem_ext_wr;
    reg dmem_ext_mem_op;

    wire [WORD_SIZE-1:0] imem_data;
    reg [31:0] imem_addr_out;
    wire [WORD_SIZE-1:0] data_from_imem_cache;
    wire [31:0] imem_ext_addr_cache;
    wire imem_ext_re_cache;
    wire imem_ext_wr_cache;
    reg imem_ext_mem_ready;
    wire imem_enable_cache;
    wire imem_cache_miss_stall;
    reg imem_ready;
    wire imem_re_en;
    wire imem_wr_en;
    reg imem_ext_re;
    reg imem_ext_wr;
    reg imem_ext_mem_op;

    wire full_imem_stall; 

    // Incoming read and write signals are always for dmem operations
    assign dmem_re_en = en_mem_re;
    assign dmem_wr_en = en_mem_wr;
    // You know it is a dmem operation if there is a read or write signal, if it is not a dmem op, then it is implied that it is an imem op
    assign dmem_op = dmem_re_en | dmem_wr_en;

    // Imem will always read and never write
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
              .cache_miss_stall(imem_cache_miss_stall),
              .ext_data_out(data_from_imem_cache),
              .ext_data_in(data_out),
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
              .cache_miss_stall(dmem_cache_miss_stall),
              .ext_data_out(data_from_dmem_cache),
              .ext_data_in(data_out),
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
            state <= #1 `IMEM_OP;
        else
            state <= #1 next_state;
    end
    
     always @(state or dmem_ready or imem_ready) begin
        case(state)
            `DMEM_OP:
                if (dmem_ready) begin // If stall finished during a dmem operation, operation is said to be finished
                    next_state <= `IMEM_OP;
                end
                else begin
                    next_state <= `DMEM_OP;
                end
            `IMEM_OP:
                if (dmem_ready & dmem_op) begin 
                    next_state   <= `DMEM_OP;
                end
                else begin
                    next_state <= `IMEM_OP;
                end
        endcase
     end

    always @(*)
    begin
        case(state)
            `DMEM_OP:
            begin
                mem_addr <= #1 dmem_addr_out;
                en_ext_mem_re <= #1 dmem_ext_re;
                en_ext_mem_wr <= #1 dmem_ext_wr;
                imem_ext_mem_ready <= #1 1'b0;
                dmem_ext_mem_ready <= #1 mem_ready;
                imem_ext_mem_op <= #1 1'b0;
                dmem_ext_mem_op <= #1 1'b1;
            end
            `IMEM_OP:
            begin
                mem_addr <= #1 imem_addr_out;
                en_ext_mem_re <= #1 imem_ext_re;
                en_ext_mem_wr <= #1 imem_ext_wr;
                imem_ext_mem_ready <= #1 mem_ready;
                dmem_ext_mem_ready <= #1 1'b0;
                imem_ext_mem_op <= #1 1'b1;
                dmem_ext_mem_op <= #1 1'b0;
            end
        endcase

        if (rst) begin
            imem_data_out <= {WORD_SIZE{1'b0}};
            imem_addr_out <= 32'b0;
            imem_ready <= 1'b1;
            imem_ext_re <= 1'b0;
            imem_ext_wr <= 1'b0;
        end
        else begin
            if (imem_enable_cache) begin
                imem_data_out <= imem_data;
                imem_addr_out <= imem_ext_addr_cache;
                imem_ready <= ~imem_cache_miss_stall;
                imem_ext_re <= imem_ext_re_cache;
                imem_ext_wr <= imem_ext_wr_cache;
            end
            else begin
                imem_data_out <= data_out & {32{mem_ready & (imem_re_en | imem_wr_en)}};
                imem_addr_out <= imem_addr;
                imem_ready <= imem_ext_mem_ready;
                imem_ext_re <= imem_re_en;
                imem_ext_wr <= imem_wr_en;
            end
        end

        if (rst) begin
            data_in <= {WORD_SIZE{1'b0}};
            dmem_data_out <= {WORD_SIZE{1'b0}};
            dmem_addr_out <= 32'b0;
            dmem_ready <= 1'b1;
            dmem_ext_re <= 1'b0;
            dmem_ext_wr <= 1'b0;
        end
        else begin
            if (dmem_enable_cache) begin
                data_in <= data_from_dmem_cache;
                dmem_data_out <= dmem_data;
                dmem_addr_out <= dmem_ext_addr_cache;
                dmem_ready <= ~dmem_cache_miss_stall;
                dmem_ext_re <= imem_ext_re_cache;
                dmem_ext_wr <= imem_ext_wr_cache;
            end
            else begin
                data_in <= dmem_data_in;
                dmem_data_out <= data_out & {32{mem_ready & (dmem_re_en | dmem_wr_en)}};
                dmem_addr_out <= dmem_addr;
                dmem_ready <= dmem_ext_mem_ready;
                dmem_ext_re <= dmem_re_en;
                dmem_ext_wr <= dmem_wr_en;
            end
        end
    end
endmodule