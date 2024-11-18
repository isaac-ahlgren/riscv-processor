
module memory_map(
    input [31:0] imem_addr,
    input [31:0] dmem_addr,
    output reg imem_cache_enable,
    output reg dmem_cache_enable
);
    wire [9:0] imem_tag;
    wire [9:0] dmem_tag;

    assign imem_tag = imem_addr[31:22];
    assign dmem_tag = dmem_addr[31:22];

    always @ (*) begin
        case(imem_tag)
            10'h0: begin
                imem_cache_enable <= 1'b1;
            end
            10'h1: begin
                imem_cache_enable <= 1'b0;
            end
            10'h2: begin
                imem_cache_enable <= 1'b1;
            end
            default: begin
                imem_cache_enable <= 1'b0;
            end
        endcase

        case(dmem_tag)
            10'h0: begin
                dmem_cache_enable <= 1'b1;
            end
            10'h1: begin
                dmem_cache_enable <= 1'b0;
            end
            10'h2: begin
                dmem_cache_enable <= 1'b1;
            end
        endcase
    end

endmodule 