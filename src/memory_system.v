`timescale 1us/100ns

`define  MAIN_MEMORY_READ_SIZE 32
module memory_system (
                        output [31:0] imem_data_out, 
                        output [31:0] dmem_data_out, 
                        input [`MAIN_MEMORY_READ_SIZE-1:0] data_out,
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
                        input ien_mem_re,
                        input ien_mem_wr,
                        output oen_mem_re,
                        output oen_mem_wr,
                        input data_hazard,
                        input control_hazard,
                        input clk,
                        input rst);

    wire dmem_use;
    wire dmem_use_delayed;

    wire imem_data_mask;
    wire dmem_data_mask;

    wire [31:0] save_slot;

    wire [31:0] data_to_proc;

    wire full_imem_stall;
    reg delayed_first_stage_stall;

    assign dmem_use = ien_mem_re | ien_mem_wr;

    assign imem_data_out = data_to_proc & {`MAIN_MEMORY_READ_SIZE{imem_data_mask}};
    assign dmem_data_out = data_to_proc & {`MAIN_MEMORY_READ_SIZE{dmem_data_mask}};
    
    assign imem_ready = mem_ready & ~dmem_use;
    assign dmem_ready = mem_ready;

    assign full_imem_stall = imem_stall & ~dmem_use & jump_taken; // Full pipeline stall for the icache if there is not a miss in the dcache and jump is going to be taken
    assign imem_stall = ~imem_ready & ~control_hazard;
    assign dmem_stall = ~dmem_ready & dmem_use;
    assign stall = dmem_stall | full_imem_stall;
    assign first_stage_stall = stall | data_hazard | (imem_stall & control_hazard); 

    assign squash = data_hazard | control_hazard;

    assign imem_data_mask = mem_ready & ~dmem_use_delayed;
    assign dmem_data_mask = mem_ready;
    
    assign oen_mem_re = (ien_mem_re | 1'b1) & ~rst; // Always requesting read because instructions are needed and there is no cache yet
    assign oen_mem_wr = ien_mem_wr;

    assign data_to_proc = delayed_first_stage_stall ? save_slot : data_out;
    
    pipeline_latch dmem_use_latch1 (.q(dmem_use_delayed),
                                    .d(dmem_use),
                                    .stall(stall),
                                    .clk(clk),
                                    .rst(rst));

    pipeline_latch save_slot_latch [31:0] (.q(save_slot),
                                    .d(data_out),
                                    .stall(delayed_first_stage_stall),
                                    .clk(clk),
                                    .rst(rst));

    always @(dmem_use or dmem_addr or imem_addr or ien_mem_re or ien_mem_wr) begin
      if (dmem_use) begin
          mem_addr = dmem_addr; 
      end
      else begin
          mem_addr = imem_addr;
      end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            delayed_first_stage_stall <= 1'b0;
        end
        else begin
            delayed_first_stage_stall <= first_stage_stall;
        end
    end

endmodule