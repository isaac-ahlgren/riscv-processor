
module hazards_controller(
                          output control_hazard,  // Signal if there is a control hazard
                          output data_hazard,     // Signal if there is a data hazard
                          output stall,           // Signal if there is a full pipeline stall
                          output dmem_stall,      // Signal if there is a data cache stall
                          output imem_stall,      // Signal if there is a instruction cache stall
                          input jump_taken,       // Signal if there is a jump taken
                          input dmem_ready,       // Signal if the data cache can be read from
                          input imem_ready,       // Signal if the instruction cache can be read from       
                          input en_mem_re,        // Signal if a memory write is enabled 
                          input en_mem_wr,        // Signal if a memory read is enabled
                          input [4:0] a0,         // 1st register identifier
                          input [4:0] a1,         // 2nd register identifier
                          input [4:0] a2,         // 3rd register identifier
                          input clk,              // Clock
                          input rst);             // Reset

    wire dmem_use;
    assign dmem_use = en_mem_re | en_mem_wr;

    wire control_hazard_input;
    wire control_hazard_latch1_conn;
    pipeline_latch control_hazard_latch1 (.q(control_hazard_latch1_conn), .d(control_hazard_input), .stall(stall | data_hazard), .clk(clk), .rst(rst));

    wire [4:0] a2_latch1_conn;
    wire a1_equal_a2_latch1;
    wire a0_equal_a2_latch1;
    wire a2_equal_zero_latch1;
    wire data_hazard_latch1;
    pipeline_latch register_wr_latch1 [4:0] (.q(a2_latch1_conn), .d(a2), .stall(stall), .clk(clk), .rst(rst));
    assign a2_equal_zero_latch1 = ~(|(a2_latch1_conn ^ 5'b0));
    assign a1_equal_a2_latch1 = ~(|(a2_latch1_conn ^ a1));
    assign a0_equal_a2_latch1 = ~(|(a2_latch1_conn ^ a0));
    assign data_hazard_latch1 = (a1_equal_a2_latch1 | a0_equal_a2_latch1) & ~a2_equal_zero_latch1;

    wire [4:0] a2_latch2_conn;
    wire a1_equal_a2_latch2;
    wire a0_equal_a2_latch2;
    wire a2_equal_zero_latch2;
    wire data_hazard_latch2;
    pipeline_latch register_wr_latch2 [4:0] (.q(a2_latch2_conn), .d(a2_latch1_conn), .stall(stall), .clk(clk), .rst(rst));
    assign a2_equal_zero_latch2 = ~(|(a2_latch2_conn ^ 5'b0));
    assign a1_equal_a2_latch2 = ~(|(a2_latch2_conn ^ a1));
    assign a0_equal_a2_latch2 = ~(|(a2_latch2_conn ^ a0));
    assign data_hazard_latch2 = (a1_equal_a2_latch2 | a0_equal_a2_latch2) & ~a2_equal_zero_latch2;

    wire [4:0] a2_latch3_conn;
    wire a1_equal_a2_latch3;
    wire a0_equal_a2_latch3;
    wire a2_equal_zero_latch3;
    wire data_hazard_latch3;
    pipeline_latch register_wr_latch3 [4:0] (.q(a2_latch3_conn), .d(a2_latch2_conn), .stall(stall), .clk(clk), .rst(rst));
    assign a2_equal_zero_latch3 = ~(|(a2_latch3_conn ^ 5'b0));
    assign a1_equal_a2_latch3 = ~(|(a2_latch3_conn ^ a1));
    assign a0_equal_a2_latch3 = ~(|(a2_latch3_conn ^ a0));
    assign data_hazard_latch3 = (a1_equal_a2_latch3 | a0_equal_a2_latch3) & ~a2_equal_zero_latch3;

    assign control_hazard_input = jump_taken;

    assign data_hazard = (data_hazard_latch1 | data_hazard_latch2 | data_hazard_latch3) & ~control_hazard; 
    assign control_hazard = control_hazard_input | control_hazard_latch1_conn;
    assign imem_stall = ~imem_ready & ~control_hazard;
    assign dmem_stall = ~dmem_ready & dmem_use;
    assign stall = dmem_stall | (imem_stall & ~dmem_use & jump_taken); // Full pipeline stall for the icache if there is not a miss in the dcache and jump is going to be taken
endmodule 