`timescale 1us/100ns

`define READ_SIZE 32 
module data_addr_bus_controller (
                                 output [`READ_SIZE-1:0] imem_data_out, 
                                 output [`READ_SIZE-1:0] dmem_data_out, 
                                 input [31:0] data_out, 
                                 output imem_ready, 
                                 output dmem_ready, 
                                 input mem_ready, 
                                 input [31:0] imem_addr, 
                                 input [31:0] dmem_addr, 
                                 output reg [31:0] mem_addr, 
                                 input dmem_use);

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