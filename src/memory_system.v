`timescale 1us/100ns

`define  MAIN_MEMORY_READ_SIZE 32
module memory_system (
                        output [31:0] imem_data_out, 
                        output [31:0] dmem_data_out, 
                        input [`MAIN_MEMORY_READ_SIZE-1:0] data_out, 
                        output imem_ready, 
                        output dmem_ready, 
                        input mem_ready, 
                        input [31:0] imem_addr, 
                        input [31:0] dmem_addr, 
                        output reg [31:0] mem_addr, 
                        input ien_mem_re,
                        input ien_mem_wr,
                        output oen_mem_re,
                        output oen_mem_wr,
                        input rst);

    wire dmem_use;

    assign dmem_use = ien_mem_re | ien_mem_wr; 
    assign imem_data_out = data_out & {`MAIN_MEMORY_READ_SIZE{mem_ready}} & {`MAIN_MEMORY_READ_SIZE{~dmem_use}};
    assign dmem_data_out = data_out & {`MAIN_MEMORY_READ_SIZE{mem_ready}};
    assign imem_ready = mem_ready & ~dmem_use;
    assign dmem_ready = mem_ready;
    assign oen_mem_re = (ien_mem_re | 1'b1) & ~rst; // Always requesting read because instructions are needed and there is no cache yet
    assign oen_mem_wr = ien_mem_wr;

    always @(dmem_use or dmem_addr or imem_addr or ien_mem_re or ien_mem_wr) begin
      if (dmem_use) begin
          mem_addr = dmem_addr; 
      end
      else begin
          mem_addr = imem_addr;
      end
    end

endmodule