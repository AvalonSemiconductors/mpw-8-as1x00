module tms1x00_ram(
`ifdef USE_POWER_PINS
	inout vccd1,	// User area 1 1.8V supply
	inout vssd1,	// User area 1 digital ground
`endif
	input [6:0] ram_addr,
	input [3:0] w_val,
	input wen,
	input clk,
	
	output [3:0] r_val
);
reg [3:0] RAM [255:0];
assign r_val = RAM[ram_addr];

always @(posedge clk) begin
	if(wen) begin
		RAM[ram_addr] <= w_val;
	end
end

endmodule
