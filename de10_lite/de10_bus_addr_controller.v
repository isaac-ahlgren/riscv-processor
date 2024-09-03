module de10_bus_addr_controller(
    input [31:0] addr,
    output en_sdram,
    output en_sys_reg);

    wire tag;

    assign tag = addr[31:22];

    always @(tag) begin
        if tag == 10'h0 begin
            en_sdram <= 1'b1;
            en_sys_reg <= 1'b0;
        end
        else begin
            en_sdram <= 1'b0;
            en_sys_reg <= 1'b1;
        end
    end

endmodule