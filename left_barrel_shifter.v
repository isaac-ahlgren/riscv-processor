
`timescale 1us/100ns

module left_barrel_shifter(in_bits, out_bits, shift_len);
    
    input   [31:0] in_bits;
    input   [4:0]  shift_len;
    output reg   [31:0] out_bits;

    always @ (*)
        case({shift_len}) 
            5'd0: begin
                out_bits = in_bits;
            end
            5'd1: begin
                out_bits[31:0] = {in_bits[30:0], 1'b0};
            end
            5'd2: begin
                out_bits[31:0] = {in_bits[29:0], 2'b0};
            end
            5'd3: begin
                out_bits[31:0] = {in_bits[28:0], 3'b0};
            end
	    5'd4: begin
                out_bits[31:0] = {in_bits[27:0], 4'b0};
            end
            5'd5: begin
                out_bits[31:0] = {in_bits[26:0], 5'b0};
            end
            5'd6: begin
                out_bits[31:0] = {in_bits[25:0], 6'b0};
            end
            5'd7: begin
                out_bits[31:0] = {in_bits[24:0], 7'b0};
            end
            5'd8: begin
                out_bits[31:0] = {in_bits[23:0], 8'b0};
            end
            5'd9: begin
                out_bits[31:0] = {in_bits[22:0], 9'b0};
            end
            5'd10: begin
                out_bits[31:0] = {in_bits[21:0], 10'b0};
            end
            5'd11: begin
                out_bits[31:0] = {in_bits[20:0], 11'b0};
            end
	    5'd12: begin
                out_bits[31:0] = {in_bits[19:0], 12'b0}; 
            end
            5'd13: begin
                out_bits[31:0] = {in_bits[18:0], 13'b0};
            end
            5'd14: begin
                out_bits[31:0] = {in_bits[17:0], 14'b0};
            end
            5'd15: begin
                out_bits[31:0] = {in_bits[16:0], 15'b0};
            end
            5'd16: begin
                out_bits[31:0] = {in_bits[15:0], 16'b0}; 
            end
            5'd17: begin
                out_bits[31:0] = {in_bits[14:0], 17'b0};
            end
            5'd18: begin
                out_bits[31:0] = {in_bits[13:0], 18'b0};
            end
            5'd19: begin
                out_bits[31:0] = {in_bits[12:0], 19'b0};
            end
	    5'd20: begin
                out_bits[31:0] = {in_bits[11:0], 20'b0};
            end
            5'd21: begin
                out_bits[31:0] = {in_bits[10:0], 21'b0};
            end
            5'd22: begin
                out_bits[31:0] = {in_bits[9:0], 22'b0};
            end
            5'd23: begin
                out_bits[31:0] = {in_bits[8:0], 23'b0};
            end
            5'd24: begin
                out_bits[31:0] = {in_bits[7:0], 24'b0}; 
            end
            5'd25: begin
                out_bits[31:0] = {in_bits[6:0], 25'b0};
            end
            5'd26: begin
                out_bits[31:0] = {in_bits[5:0], 26'b0};
            end
            5'd27: begin
                out_bits[31:0] = {in_bits[4:0], 27'b0};
            end
	    5'd28: begin
                out_bits[31:0] = {in_bits[3:0], 28'b0};
            end
            5'd29: begin
                out_bits[31:0] = {in_bits[2:0], 29'b0};
            end
            5'd30: begin
                out_bits[31:0] = {in_bits[1:0], 30'b0};
            end
            5'd31: begin
                out_bits[31:0] = {in_bits[0], 31'b0};
            end
            default: begin
                out_bits[31:0] = {32'b0};
            end
    endcase
  
endmodule     
 