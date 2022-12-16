module wb_decode(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif
	input wb_clk_i,
	input [31:0] wbs_adr_i,
	input wbs_we_i,
	output ram_csb,
	output ram_web,
	output [8:0] ram_adrb
);
	assign ram_csb = ~wbs_adr_i[16];
	assign ram_web = ~wbs_we_i;
	assign ram_adrb = wbs_adr_i[8:0];
endmodule
