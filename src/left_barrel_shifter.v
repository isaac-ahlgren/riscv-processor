
`timescale 1us/100ns

module left_barrel_shifter(
                           input [31:0] idata, 
                           output reg [31:0] odata, 
                           input [4:0] shift_len);

    always @ (*)
        case({shift_len}) 
            5'd0: begin
                odata = idata;
            end
            5'd1: begin
                odata[31:0] = {idata[30:0], 1'b0};
            end
            5'd2: begin
                odata[31:0] = {idata[29:0], 2'b0};
            end
            5'd3: begin
                odata[31:0] = {idata[28:0], 3'b0};
            end
	    5'd4: begin
                odata[31:0] = {idata[27:0], 4'b0};
            end
            5'd5: begin
                odata[31:0] = {idata[26:0], 5'b0};
            end
            5'd6: begin
                odata[31:0] = {idata[25:0], 6'b0};
            end
            5'd7: begin
                odata[31:0] = {idata[24:0], 7'b0};
            end
            5'd8: begin
                odata[31:0] = {idata[23:0], 8'b0};
            end
            5'd9: begin
                odata[31:0] = {idata[22:0], 9'b0};
            end
            5'd10: begin
                odata[31:0] = {idata[21:0], 10'b0};
            end
            5'd11: begin
                odata[31:0] = {idata[20:0], 11'b0};
            end
	    5'd12: begin
                odata[31:0] = {idata[19:0], 12'b0}; 
            end
            5'd13: begin
                odata[31:0] = {idata[18:0], 13'b0};
            end
            5'd14: begin
                odata[31:0] = {idata[17:0], 14'b0};
            end
            5'd15: begin
                odata[31:0] = {idata[16:0], 15'b0};
            end
            5'd16: begin
                odata[31:0] = {idata[15:0], 16'b0}; 
            end
            5'd17: begin
                odata[31:0] = {idata[14:0], 17'b0};
            end
            5'd18: begin
                odata[31:0] = {idata[13:0], 18'b0};
            end
            5'd19: begin
                odata[31:0] = {idata[12:0], 19'b0};
            end
	    5'd20: begin
                odata[31:0] = {idata[11:0], 20'b0};
            end
            5'd21: begin
                odata[31:0] = {idata[10:0], 21'b0};
            end
            5'd22: begin
                odata[31:0] = {idata[9:0], 22'b0};
            end
            5'd23: begin
                odata[31:0] = {idata[8:0], 23'b0};
            end
            5'd24: begin
                odata[31:0] = {idata[7:0], 24'b0}; 
            end
            5'd25: begin
                odata[31:0] = {idata[6:0], 25'b0};
            end
            5'd26: begin
                odata[31:0] = {idata[5:0], 26'b0};
            end
            5'd27: begin
                odata[31:0] = {idata[4:0], 27'b0};
            end
	    5'd28: begin
                odata[31:0] = {idata[3:0], 28'b0};
            end
            5'd29: begin
                odata[31:0] = {idata[2:0], 29'b0};
            end
            5'd30: begin
                odata[31:0] = {idata[1:0], 30'b0};
            end
            5'd31: begin
                odata[31:0] = {idata[0], 31'b0};
            end
            default: begin
                odata[31:0] = {32'b0};
            end
    endcase
  
endmodule     
 