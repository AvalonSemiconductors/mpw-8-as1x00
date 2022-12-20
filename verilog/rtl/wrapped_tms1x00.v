module wrapped_tms1x00(
`ifdef USE_POWER_PINS
	inout vccd1,	// User area 1 1.8V supply
	inout vssd1,	// User area 1 digital ground
`endif
	input [37:0] io_in,
	output [37:0] io_out,
	output [37:0] io_oeb,

	output [8:0] oram_addr,
	output oram_csb,
	input [31:0] oram_value,

	input wb_clk_i,
	input wb_rst_i,

	//Wishbone interface stuffs
	input [31:0] wbs_adr_i,
	input wbs_dat_i,
	input wbs_we_i,
	input wbs_cyc_i,
	input wbs_stb_i,
	output wbs_ack_o,

	output ram_csb,
	output ram_web,
	output [8:0] ram_adrb,
	output [3:0] ram_wmask
);

wire [10:0] byte_address;
assign oram_addr = byte_address[10:2];
wire [7:0] byte_value = oram_value >> byte_address[1:0];

assign valid = wbs_cyc_i && wbs_stb_i;

assign io_oeb = 38'b00000000000000000000000000000000011111;

reg wb_debug;
reg ready;
assign wbs_ack_o = ready;
wire wb_debug_new = wbs_adr_i[23] && valid && wbs_we_i ? wbs_dat_i : wb_debug;
always @(posedge wb_clk_i) begin
	ready <= wbs_we_i && valid;
	wb_debug <= wb_debug_new;
end
assign io_out[37] = wb_debug;

assign ram_csb = ~wbs_adr_i[16] | ~valid;
assign ram_web = ~wbs_we_i;
assign ram_adrb = wbs_adr_i[8:0];
assign oram_csb = wb_rst_i;
assign ram_wmask = 4'b1111;

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
