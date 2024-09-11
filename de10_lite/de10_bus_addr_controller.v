module de10_bus_addr_controller(
    input [31:0] addr,
    output oen_sdram,
    output oen_peripherals);

    wire [9:0] tag;
    reg en_sdram;
    reg en_peripherals;

    assign tag = addr[31:22];
    assign oen_sdram = en_sdram;
    assign oen_peripherals = en_peripherals;

    always @ (tag) begin
        if (tag == 10'h0) begin
            en_sdram <= 1'b1;
            en_peripherals <= 1'b0;
        end
        else if (tag == 10'h1) begin
            en_sdram <= 1'b0;
            en_peripherals <= 1'b1;
        end
        else begin
            en_sdram <= 1'b0;
            en_peripherals = 1'b0;
        end
    end

endmodule