`include "latch.v"

module hazards_controller(control_hazard, data_hazard, stall, jump_taken, dcache_stall, icache_stall, a0, a1, a2, clk, rst);  
 
    output wire control_hazard;
    output wire data_hazard;
    output wire stall;

    input wire jump_taken;
    input wire dcache_stall;
    input wire icache_stall;
    input wire [4:0] a0;
    input wire [4:0] a1;
    input wire [4:0] a2;
    input wire clk, rst;
   
    wire a1_equal_a2;
    wire a0_equal_a2;
    wire a2_equal_zero;

    wire instr1_control_hazard_input;
    wire instr1_control_hazard_latch1_conn;
    wire instr1_control_hazard_latch2_conn;
    latch instr1_control_hazard_latch1 (.q(instr1_control_hazard_latch1_conn), .d(instr1_control_hazard_input), .stall(stall), .clk(clk), .rst(rst));
    latch instr1_control_hazard_latch2 (.q(instr1_control_hazard_latch2_conn), .d(instr1_control_hazard_latch1_conn), .stall(stall), .clk(clk), .rst(rst));

    wire instr2_control_hazard_input;
    wire instr2_control_hazard_latch1_conn;
    wire instr2_control_hazard_latch2_conn;
    wire instr2_control_hazard_latch3_conn;
    latch instr2_control_hazard_latch1 (.q(instr2_control_hazard_latch1_conn), .d(instr2_control_hazard_input), .stall(stall), .clk(clk), .rst(rst));
    latch instr2_control_hazard_latch2 (.q(instr2_control_hazard_latch2_conn), .d(instr2_control_hazard_latch1_conn), .stall(stall), .clk(clk), .rst(rst));
    latch instr2_control_hazard_latch3 (.q(instr2_control_hazard_latch3_conn), .d(instr2_control_hazard_latch2_conn), .stall(stall), .clk(clk), .rst(rst));

    wire [4:0] a2_latch1_conn;
    latch register_wr_latch1 [4:0] (.q(a2_latch1_conn), .d(a2), .stall(stall), .clk(clk), .rst(rst));

    assign instr1_control_hazard_input = jump_taken;
    assign instr2_control_hazard_input = jump_taken;

    assign a2_equal_zero = ~(|(a2_latch1_conn ^ 5'b0));
    assign a1_equal_a2 = ~(|(a2_latch1_conn ^ a1));
    assign a0_equal_a2 = ~(|(a2_latch1_conn ^ a0));
    assign data_hazard = (a1_equal_a2 | a0_equal_a2) & ~a2_equal_zero; 
    assign stall = dcache_stall | icache_stall;
    assign control_hazard = instr1_control_hazard_latch2_conn | instr2_control_hazard_latch3_conn;      
endmodule 