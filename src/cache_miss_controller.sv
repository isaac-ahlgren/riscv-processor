`timescale 1us/100ns

`define CONTROLLER_IDLE        4'b0000
`define CONTROLLER_READ        4'b0001
`define CONTROLLER_READING     4'b0011
`define CONTROLLER_WRITE       4'b0010
`define CONTROLLER_READ_FIN    4'b0100
`define CONTROLLER_WRITE_FIN   4'b1000
`define CONTROLLER_CACHE_WRITE 4'b0111

module cache_miss_controller#(parameter BYTES_PER_WORD = 4,
                              parameter WORD_SIZE = 32,
                              parameter INDEX_BITS = 5, // Index into cache
                              parameter CACHE_LINES = 2**INDEX_BITS, // Number of cache lines
                              parameter BLOCK_OFFSET = 6,
                              parameter DATA_LENGTH = 2**BLOCK_OFFSET, // Cache line length in bytes
                              parameter TAG_BITS = 32 - INDEX_BITS - BLOCK_OFFSET,
                              parameter STATUS_BITS = 1,
                              parameter LINE_LENGTH = TAG_BITS + DATA_LENGTH*8 + STATUS_BITS,
                              parameter WORDS_PER_DATA_BLOCK = DATA_LENGTH / BYTES_PER_WORD)
    (
    input [31:0] addr,
    input [WORD_SIZE-1:0] data_from_cache,
    output reg [LINE_LENGTH-1:0] data_to_cache,
    input [WORD_SIZE-1:0] ext_data_in,
    output reg [WORD_SIZE-1:0] ext_data_out,
    output [31:0] ext_addr,
    input ext_ack,
    output reg ext_re,
    output reg ext_wr,
    output reg wr_ack,
    output reg re_ack,
    input re,
    input wr,
    output reg full_line_wr,
    input enable,
    input clk,
    input rst
    );

    wire [TAG_BITS-1:0] tag;

    reg [DATA_LENGTH*8-1:0] data;
    reg read_into_data;
    reg [3:0] state;
    reg update_addr;
    reg [7:0]  counter;
    reg [31:0] curr_addr;
    reg ctr_rst;
    reg update_counter;

    assign tag = addr[31:INDEX_BITS+BLOCK_OFFSET];
    assign ext_addr = curr_addr;

    always @(posedge update_addr or posedge update_counter or posedge ctr_rst or posedge rst or posedge enable)
    begin
        if (ctr_rst | rst | ~enable) begin
            counter <= #1 8'b0;
            curr_addr <= #1 32'b0;
        end
        else begin
            if(update_addr) begin
                if (update_counter) begin
                    counter <= #1 (counter + 1'b1);
                    curr_addr <= #1 curr_addr + 4;
                end
                else begin
                    counter <= #1 counter;
                    if (counter == 0) begin
                        if (wr) begin
                            curr_addr <= #1 addr;
                        end
                        else begin
                            curr_addr <= #1 addr & ~32'b111111;
                        end
                    end
                    else begin
                        curr_addr <= #1 curr_addr;
                    end 
                end
            end 
            else begin
                counter <= #1 counter;
                curr_addr <= #1 curr_addr; 
            end
        end
    end
    assign data_count   = (counter == (DATA_LENGTH >> 2));

    always @(posedge read_into_data or posedge rst)
    begin
        if (rst) begin
            data <= #1 {DATA_LENGTH*8{1'b0}};
        end
        else begin
            data <= #1 ((data >> WORD_SIZE) | {ext_data_in, {DATA_LENGTH*8-WORD_SIZE{1'b0}}});
        end
    end

    always @(posedge clk) begin
        if (rst | ~enable) begin
            state <= `CONTROLLER_IDLE;
        end
        else begin
            case(state)
                `CONTROLLER_IDLE:
                    if(wr | re) begin
                        if (wr) begin
                            state   <= `CONTROLLER_WRITE;
                        end
                        else begin
                            state   <= `CONTROLLER_READ;
                        end
                    end
                    else begin
                        state   <= `CONTROLLER_IDLE;
                    end
                `CONTROLLER_WRITE:
                    if (ext_ack) begin
                        state <= `CONTROLLER_WRITE_FIN;
                    end
                    else begin
                        state       <= `CONTROLLER_WRITE;
                    end
                `CONTROLLER_WRITE_FIN:
                    state <= `CONTROLLER_IDLE;
                `CONTROLLER_READ:
                    if (data_count) begin
                        state <= `CONTROLLER_CACHE_WRITE;
                    end
                    else begin
                        if (ext_ack) begin
                            state <= `CONTROLLER_READING;
                        end
                        else begin
                            state <= `CONTROLLER_READ;
                        end
                    end
                `CONTROLLER_READING:
                    if (data_count) begin
                        state <= `CONTROLLER_CACHE_WRITE;
                    end
                    else begin
                        if (ext_ack) begin
                            state <= `CONTROLLER_READ;
                        end
                        else begin
                            state <= `CONTROLLER_READING;
                        end
                    end
                `CONTROLLER_CACHE_WRITE:
                    state <= `CONTROLLER_READ_FIN;
                `CONTROLLER_READ_FIN:
                    state <= `CONTROLLER_IDLE;
                default:
                    state       <= `CONTROLLER_IDLE;
            endcase
        end
    end

    always @(state)
    begin
    case(state)
        `CONTROLLER_IDLE:
        begin
            data_to_cache <= #2 {LINE_LENGTH{1'b0}};
            ext_data_out  <= #2 {WORD_SIZE{1'b0}};
            read_into_data <= #2 1'b0;
            ext_re <= #2 1'b0;
            ext_wr <= #2 1'b0;
            full_line_wr <= #2 1'b0;
            wr_ack <= #2 1'b0;
            re_ack <= #2 1'b0;
            update_addr <= #2 1'b0;
            update_counter <= #2 1'b0;
            ctr_rst <= #2 1'b1;
        end
        `CONTROLLER_WRITE:
        begin
            data_to_cache <= #2 {LINE_LENGTH{1'b0}};
            ext_data_out  <= #2 data_from_cache;
            read_into_data <= #2 1'b0;
            ext_re <= #2 1'b0;
            ext_wr <= #2 1'b1;
            full_line_wr <= #2 1'b0;
            wr_ack <= #2 1'b0;
            re_ack <= #2 1'b0;
            update_addr <= #2 1'b1;
            update_counter <= #2 1'b0;
            ctr_rst <= #2 1'b0;
        end
        `CONTROLLER_WRITE_FIN:
        begin
            data_to_cache <= #2 {LINE_LENGTH{1'b0}};
            ext_data_out  <= #2 data_from_cache;
            read_into_data <= #2 1'b0;
            ext_re <= #2 1'b0;
            ext_wr <= #2 1'b0;
            full_line_wr <= #2 1'b0;
            wr_ack <= #2 1'b1;
            re_ack <= #2 1'b0;
            update_addr <= #2 1'b0;
            update_counter <= #2 1'b0;
            ctr_rst <= #2 1'b0;
        end
        `CONTROLLER_READ:
        begin
            data_to_cache <= #2 {LINE_LENGTH{1'b0}};
            ext_data_out  <= #2 {WORD_SIZE{1'b0}};
            read_into_data <= #2 1'b0;
            ext_re <= #2 1'b1;
            ext_wr <= #2 1'b0;
            full_line_wr <= #2 1'b0;
            wr_ack <= #2 1'b0;
            re_ack <= #2 1'b0;
            update_addr <= #2 1'b1;
            update_counter <= #2 1'b0;
            ctr_rst <= #2 1'b0;
        end
        `CONTROLLER_READING:
        begin
            data_to_cache <= #2 {LINE_LENGTH{1'b0}};
            ext_data_out  <= #2 {WORD_SIZE{1'b0}};
            read_into_data <= #2 1'b1;
            ext_re <= #2 1'b1;
            ext_wr <= #2 1'b0;
            full_line_wr <= #2 1'b0;
            wr_ack <= #2 1'b0;
            re_ack <= #2 1'b0;
            update_addr <= #2 1'b1;
            update_counter <= #2 1'b1;
            ctr_rst <= #2 1'b0;
        end
        `CONTROLLER_CACHE_WRITE:
        begin
            data_to_cache <= #2 {tag, data, 1'b1};
            ext_data_out  <= #2 {WORD_SIZE{1'b0}};
            read_into_data <= #2 1'b1;
            ext_re <= #2 1'b0;
            ext_wr <= #2 1'b0;
            full_line_wr <= #2 1'b1;
            wr_ack <= #2 1'b0;
            re_ack <= #2 1'b0;
            update_addr <= #2 1'b0;
            update_counter <= #2 1'b0;
            ctr_rst <= #2 1'b0;
        end
        `CONTROLLER_READ_FIN:
        begin
            data_to_cache <= #2 {LINE_LENGTH{1'b0}};
            ext_data_out  <= #2 {WORD_SIZE{1'b0}};
            read_into_data <= #2 1'b0;
            ext_re <= #2 1'b0;
            ext_wr <= #2 1'b0;
            full_line_wr <= #2 1'b0;
            wr_ack <= #2 1'b0;
            re_ack <= #2 1'b1;
            update_addr <= #2 1'b0;
            update_counter <= #2 1'b0;
            ctr_rst <= #2 1'b0;
        end
    endcase
    end

endmodule