module wrapped_tms1x00(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif
    input [37:0] io_in,
    output [37:0] io_out,
    output [37:0] io_oeb,

    output [8:0] oram_addr,
    input [31:0] oram_value,

    input wb_clk_i,
    input wb_rst_i
);

wire [10:0] byte_address;
assign oram_addr = byte_address[10:2];
wire [7:0] byte_value = oram_value >> byte_address[1:0];

assign io_oeb = 'b10000000000000000000000000000000011111;

tms1x00 tms1x00(
    .reset(wb_rst_i),
    .clk(wb_clk_i),
    .chip_sel(io_in[5]),
    .K_in(io_in[9:6]),
    .O_out(io_out[17:10]),
    .R_out(io_out[33:18]),
    .rom_addr(byte_address),
    .rom_value(byte_value)
);

endmodule
