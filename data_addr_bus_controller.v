`timescale 1us/100ns

`define READ_SIZE 32 
module data_addr_bus_controller (imem_data_out, dmem_data_out, data_out, imem_ready, dmem_ready, mem_ready, 
                                 imem_addr, dmem_addr, mem_addr, dmem_use);

    output reg     [`READ_SIZE-1:0] imem_data_out;
    output reg     [`READ_SIZE-1:0] dmem_data_out;
    output reg     [31:0] mem_addr;
    output         imem_ready;
    output         dmem_ready;
    input          [`READ_SIZE-1:0] data_out;
    input          mem_ready;
    input          dmem_use;
    input          [31:0] imem_addr;
    input          [31:0] dmem_addr;

    assign imem_data_out = data_out & {`READ_SIZE{mem_ready}} & {`READ_SIZE{~dmem_use}};
    assign dmem_data_out = data_out & {`READ_SIZE{mem_ready}};
    assign imem_ready = mem_ready & ~dmem_use;
    assign dmem_ready = mem_ready;

    always @(*) begin
      if (dmem_use) begin
          mem_addr = dmem_addr;
      end
      else begin
          mem_addr = imem_addr;
      end
    end

endmodule