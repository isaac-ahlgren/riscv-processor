
`timescale 1us/100ns

`

module data_write_controller(wr_data, func, out_write_data)
    input wr_data;
    input [2:0] func;
    output reg out_write_data;

    case({func})
    endcase

endmodule