`include "latch.v"

module hazards_controller(control_hazard, data_hazard, stall, jump_taken, dmem_stall, imem_stall, a0, a1, a2, clk, rst);  
 
    output wire control_hazard;
    output wire data_hazard;
    output wire stall;

    input wire jump_taken;
    input wire dmem_stall;
    input wire imem_stall;
    input wire [4:0] a0;
    input wire [4:0] a1;
    input wire [4:0] a2;
    input wire clk, rst;
   
    wire a1_equal_a2;
    wire a0_equal_a2;
    wire a2_equal_zero;

    wire control_hazard_input;
    wire control_hazard_latch_conn;
    latch control_hazard_latch (.q(control_hazard_latch_conn), .d(control_hazard_input), .stall(stall | data_hazard), .clk(clk), .rst(rst));
        
    wire [4:0] a2_latch1_conn;
    latch register_wr_latch1 [4:0] (.q(a2_latch1_conn), .d(a2), .stall(stall), .clk(clk), .rst(rst));

    assign control_hazard_input = jump_taken;

    assign a2_equal_zero = ~(|(a2_latch1_conn ^ 5'b0));
    assign a1_equal_a2 = ~(|(a2_latch1_conn ^ a1));
    assign a0_equal_a2 = ~(|(a2_latch1_conn ^ a0));
    assign data_hazard = (a1_equal_a2 | a0_equal_a2) & ~a2_equal_zero & ~control_hazard; 
    assign stall = dmem_stall | imem_stall;
    assign control_hazard = control_hazard_input | control_hazard_latch_conn;      
endmodule 