module de10_bus_controller(
    input [31:0] addr,
    input [31:0] sram_data,
    input [31:0] sdram_data,
    input [31:0] peripheral_data, 
    output oen_sram,
    output oen_sdram,
    output oen_peripherals,
    output reg [31:0] odata);

    wire [9:0] tag;

    reg en_sram;
    reg en_sdram;
    reg en_peripherals;

    assign tag = addr[31:22];

   

    assign oen_sram = en_sram;
    assign oen_sdram = en_sdram;
    assign oen_peripherals = en_peripherals;

    always @ (*) begin
        if (tag == 10'h0) begin
            odata <= sram_data;
            en_sram <= 1'b1;
            en_sdram <= 1'b0;
            en_peripherals <= 1'b0;
        end
        else if (tag == 10'h1) begin
            odata <= peripheral_data;
            en_sram <= 1'b0;
            en_sdram <= 1'b0;
            en_peripherals <= 1'b1;
        end
        else if (tag == 10'h2) begin
            odata <= sdram_data;
            en_sram <= 1'b0;
            en_sdram <= 1'b1;
            en_peripherals <= 1'b0;
        end
        else begin
            odata <= 32'b0;
            en_sram <= 1'b0;
            en_sdram <= 1'b0;
            en_peripherals <= 1'b0;
        end
    end

endmodule