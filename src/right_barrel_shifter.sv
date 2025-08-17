`timescale 1us/100ns

module right_barrel_shifter(
                            input [31:0] idata, 
                            output reg [31:0] odata, 
                            input [4:0] shift_len, 
                            input arithmetic);
    
    wire           shift_bit;

    assign shift_bit = arithmetic & idata[31];
  
    always @ (*)
        case({shift_len}) 
            5'd0: begin
                odata = idata;
            end
            5'd1: begin
                odata[31:0] = {{1{shift_bit}}, idata[31:1]};
            end
            5'd2: begin
                odata[31:0] = {{2{shift_bit}}, idata[31:2]};
            end
            5'd3: begin
                odata[31:0] = {{3{shift_bit}}, idata[31:3]};
            end
	    5'd4: begin
                odata[31:0] = {{4{shift_bit}}, idata[31:4]};
            end
            5'd5: begin
                odata[31:0] = {{5{shift_bit}}, idata[31:5]};
            end
            5'd6: begin
                odata[31:0] = {{6{shift_bit}}, idata[31:6]};
            end
            5'd7: begin
                odata[31:0] = {{7{shift_bit}}, idata[31:7]};
            end
            5'd8: begin
                odata[31:0] = {{8{shift_bit}}, idata[31:8]};
            end
            5'd9: begin
                odata[31:0] = {{9{shift_bit}}, idata[31:9]};
            end
            5'd10: begin
                odata[31:0] = {{10{shift_bit}}, idata[31:10]};
            end
            5'd11: begin
                odata[31:0] = {{11{shift_bit}}, idata[31:11]};
            end
	    5'd12: begin
                odata[31:0] = {{12{shift_bit}}, idata[31:12]}; 
            end
            5'd13: begin
                odata[31:0] = {{13{shift_bit}}, idata[31:13]};
            end
            5'd14: begin
                odata[31:0] = {{14{shift_bit}}, idata[31:14]};
            end
            5'd15: begin
                odata[31:0] = {{15{shift_bit}}, idata[31:15]};
            end
            5'd16: begin
                odata[31:0] = {{16{shift_bit}}, idata[31:16]}; 
            end
            5'd17: begin
                odata[31:0] = {{17{shift_bit}}, idata[31:17]};
            end
            5'd18: begin
                odata[31:0] = {{18{shift_bit}}, idata[31:18]};
            end
            5'd19: begin
                odata[31:0] = {{19{shift_bit}}, idata[31:19]};
            end
	    5'd20: begin
                odata[31:0] = {{20{shift_bit}}, idata[31:20]};
            end
            5'd21: begin
                odata[31:0] = {{21{shift_bit}}, idata[31:21]};
            end
            5'd22: begin
                odata[31:0] = {{22{shift_bit}}, idata[31:22]};
            end
            5'd23: begin
                odata[31:0] = {{23{shift_bit}}, idata[31:23]};
            end
            5'd24: begin
                odata[31:0] = {{24{shift_bit}}, idata[31:24]}; 
            end
            5'd25: begin
                odata[31:0] = {{25{shift_bit}}, idata[31:25]};
            end
            5'd26: begin
                odata[31:0] = {{26{shift_bit}}, idata[31:26]};
            end
            5'd27: begin
                odata[31:0] = {{27{shift_bit}}, idata[31:27]};
            end
	    5'd28: begin
                odata[31:0] = {{28{shift_bit}}, idata[31:28]};
            end
            5'd29: begin
                odata[31:0] = {{29{shift_bit}}, idata[31:29]};
            end
            5'd30: begin
                odata[31:0] = {{30{shift_bit}}, idata[31:30]};
            end
            5'd31: begin
                odata[31:0] = {{31{shift_bit}}, idata[31]};
            end
            default: begin
                odata[31:0] = {{32{shift_bit}}};
            end
    endcase
  
endmodule     
 