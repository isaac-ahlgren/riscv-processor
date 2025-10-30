module de10_bus_controller(
    input [31:0] addr,
    input [31:0] sram_data,
    input [31:0] sdram_data,
    input [31:0] peripheral_data,
    input sram_ready,
    input sdram_ready,
    input peripheral_ready, 
    output oen_sram,
    output oen_sdram,
    output oen_peripherals,
    output reg [31:0] odata,
    output omem_ready,
    input clk,
    input rst);

    wire [9:0] tag;

    reg en_sram;
    reg en_sdram;
    reg en_peripherals;
    reg mem_ready;

    assign tag = addr[31:22];

    assign oen_sram = en_sram;
    assign oen_sdram = en_sdram;
    assign oen_peripherals = en_peripherals;
    assign omem_ready = mem_ready;

    always @ (*) begin
        if (tag == 10'h0) begin
            en_sram <= 1'b1;
            en_sdram <= 1'b0;
            en_peripherals <= 1'b0;
            mem_ready <= sram_ready;
        end
        else if (tag == 10'h1) begin
            en_sram <= 1'b0;
            en_sdram <= 1'b0;
            en_peripherals <= 1'b1;
            mem_ready <= peripheral_ready;
        end
        else if (tag == 10'h2) begin
            en_sram <= 1'b0;
            en_sdram <= 1'b1;
            en_peripherals <= 1'b0;
            mem_ready <= sdram_ready;
        end
        else begin
            en_sram <= 1'b0;
            en_sdram <= 1'b0;
            en_peripherals <= 1'b0;
            mem_ready <= 1'b1;
        end
    end

    always @ (*) begin
        if (tag == 10'h0) begin
            odata <= sram_data;
        end
        else if (tag == 10'h1) begin
            odata <= peripheral_data;
        end
        else if (tag == 10'h2) begin
            odata <= sdram_data;
        end
        else begin
            odata <= 32'b0;
        end
    end

endmodule