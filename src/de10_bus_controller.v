module de10_bus_addr_controller(
    input [31:0] addr,
    input [31:0] sram_data,
    input [31:0] sdram_data,
    input [31:0] peripheral_data, 
    output oen_sram,
    output oen_sdram,
    output oen_peripherals,
    output [31:0] odata);

    wire [9:0] tag;

    reg [31:0] data;

    reg en_sram;
    reg en_sdram;
    reg en_peripherals;

    assign tag = addr[31:22];

   

    assign oen_sram = en_sram;
    assign oen_sdram = en_sdram;
    assign oen_peripherals = en_peripherals;

    always @ (tag) begin
        if (tag == 10'h0) begin
            data <= sdram_data;
            en_sram <= 1'b1;
            en_sdram <= 1'b0;
            en_peripherals <= 1'b0;
        end
        else if (tag == 10'h1) begin
            data <= peripheral_data;
            en_sram <= 1'b0;
            en_sdram <= 1'b0;
            en_peripherals <= 1'b1;
        end
        else if (tag == 10'h2) begin
            data <= sdram_data;
            en_sram <= 1'b0;
            en_sdram <= 1'b1;
            en_peripherals <= 1'b0;
        end
        else begin
            data <= 32'b0;
            en_sram <= 1'b0;
            en_sdram <= 1'b0;
            en_peripherals <= 1'b0;
        end
    end

endmodule