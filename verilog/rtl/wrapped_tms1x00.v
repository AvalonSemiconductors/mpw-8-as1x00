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
	input [31:0] wbs_dat_i,
	output [31:0] wbs_dat_o,
	input wbs_we_i,
	input wbs_cyc_i,
	input wbs_stb_i,
	output wbs_ack_o,

	//Program memory signals
	output ram_csb,
	output ram_web,
	output [8:0] ram_adrb,
	input [31:0] ram_val
);

reg wb_rst_override;
reg wb_step;
reg chip_sel_override;
reg [3:0] K_override;
reg [31:0] wbs_o_buff;
wire status_d;

wire reset = wb_rst_i | wb_rst_override;
wire [10:0] byte_address;
assign oram_addr = byte_address[10:2];
reg [7:0] byte_value;
always @(oram_value) begin
	case(byte_address[1:0])
		0: byte_value = oram_value[7:0];
		1: byte_value = oram_value[15:8];
		2: byte_value = oram_value[23:16];
		3: byte_value = oram_value[31:24];
	endcase
end
assign oram_csb = reset;

assign io_oeb = 38'b00000000000000000000000000001111111111;

/* Wishbone decode */
assign valid = wbs_cyc_i && wbs_stb_i;
assign ram_csb = ~wbs_adr_i[16] | ~valid;
assign ram_web = ~wbs_we_i;
assign ram_adrb = wbs_adr_i[10:2];

reg wb_override;
reg ready;
reg feedback_delay;
assign wbs_ack_o = ready;
assign wbs_dat_o = wbs_adr_i[23] ? wbs_o_buff : ram_val;
always @(posedge wb_clk_i) begin
	if(wb_rst_i) begin
		wb_override <= 0;
		wb_rst_override <= 0;
		wb_step <= 0;
		wbs_o_buff <= 0;
	end
	if(valid && wbs_adr_i[23]) begin
		if(wbs_we_i) begin
			wb_override <= wbs_dat_i[0];
			wb_rst_override <= wbs_dat_i[0] & wbs_dat_i[1];
			wb_step <= wbs_dat_i[0] & wbs_dat_i[2];
			chip_sel_override <= wbs_dat_i[0] & wbs_dat_i[3];
			K_override <= wbs_dat_i[11:8];
		end else begin
			wbs_o_buff <= {7'b0, status_d, io_out[33:10]};
		end
	end
	#5;
	//Delay wbs_ack_o by one full clock cycle
	feedback_delay <= valid;
	ready <= feedback_delay;
end
assign io_out[37] = wb_override;

wire chip_sel_i = wb_override ? chip_sel_override : io_in[5];
wire [3:0] K_in = wb_override ? K_override : io_in[9:6];
/* end Wishbone decode */

assign io_out[35:34] = 2'b00;

tms1x00 tms1x00(
    .reset(reset),
    .clk(wb_clk_i),
    .chip_sel_i(chip_sel_i),
    .K_in(K_in),
    .O_out(io_out[17:10]),
    .R_out(io_out[33:18]),
    .rom_addr(byte_address),
    .rom_value_lsb(byte_value),
	.chip_sel_o(io_out[36]),

    //Wishbone overrides & debug signals
	.wb_override(wb_override),
	.wb_step(wb_step),
	.status_d(status_d)
);

endmodule
