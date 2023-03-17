// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
`default_nettype none

module tms1x00(
	input reset,
	input chip_sel_i,
	output [7:0] O_out,
	output [15:0] R_out,
	input [3:0] K_in,
	input clk,

	output [10:0] rom_addr,
	input [7:0] rom_value_raw,

	output chip_sel_o,
	
	//RAM Access
	output [6:0] ram_addr,
	input [3:0] ram_val_in,
	output [3:0] ram_val_out,
	output ram_we,

	/* Wishbone overrides & debug signals */
	input wb_override,
	input wb_step,
	output status_d,
	output [2:0] X_d,
	input pla_override, //Enable PLA override to set custom PLA values
	input [31:0] pla_val_in, //Value to be written into selected PLA register
	input [6:0] pla_addr, //Address for writing PLA regs. Format: RRAAAAA, R=Array addr, A=Value index
	input pla_write, //Write enable for PLA. Once activated, PLA override is activated. Default values are no longer loaded on reset. Signal must be held high to persist custom PLA values.
	output [31:0] pla_val_out
);
wire [7:0] rom_value = rom_value_raw;
//wire [7:0] rom_value = {rom_value_lsb[0], rom_value_lsb[1], rom_value_lsb[2], rom_value_lsb[3], rom_value_lsb[4], rom_value_lsb[5], rom_value_lsb[6], rom_value_lsb[7]};

/* CPU registers */
reg [3:0] A;	//Accumulator
reg [3:0] P;	//P ALU input
reg [3:0] N;	//N ALU input
reg [2:0] X;
reg [3:0] Y;

reg [5:0] PC;	//Program counter
reg [5:0] SR;	//Subroutine Register
reg [3:0] PA;	//Page Address
reg [3:0] PB;	//Page Buffer
reg CA;			//Chapter Address
reg CB;			//Chapter Buffer
reg CS;			//Chapter Subroutine

reg status;		//Status
reg SL;         //Status Latch
reg CL;         //Call Latch
assign status_d = status;
assign X_d = X;

//I/Os
reg [4:0] O_latch;
reg [15:0] R_latch;
reg [3:0] K_latch;

reg [2:0] cycle;
reg [7:0] ins_in;
reg [15:0] ins_pla_ands [29:0];
reg [29:0] ins_pla_ors [15:0];
reg [9:0] O_pla_ands [19:0];
reg [19:0] O_pla_ors [7:0];

reg chip_sel;
assign chip_sel_o = chip_sel;

assign R_out = R_latch;

wire [7:0] ins_arg = { ins_in[0], ins_in[1], ins_in[2], ins_in[3], ins_in[4], ins_in[5], ins_in[6], ins_in[7] };

/*#region O_PLA*/

wire [9:0] O_pla_ins = {
	O_latch[4],
	~O_latch[4],
	O_latch[3],
	~O_latch[3],
	O_latch[2],
	~O_latch[2],
	O_latch[1],
	~O_latch[1],
	O_latch[0],
	~O_latch[0]
};

wire [19:0] O_and_outs;
genvar i;
generate
	for(i = 0; i < 20; i = i + 1) begin
		assign O_and_outs[i] = 
			(O_pla_ins[0] | ~O_pla_ands[i][0]) &
			(O_pla_ins[1] | ~O_pla_ands[i][1]) &
			(O_pla_ins[2] | ~O_pla_ands[i][2]) &
			(O_pla_ins[3] | ~O_pla_ands[i][3]) &
			(O_pla_ins[4] | ~O_pla_ands[i][4]) &
			(O_pla_ins[5] | ~O_pla_ands[i][5]) &
			(O_pla_ins[6] | ~O_pla_ands[i][6]) &
			(O_pla_ins[7] | ~O_pla_ands[i][7]) &
			(O_pla_ins[8] | ~O_pla_ands[i][8]) &
			(O_pla_ins[9] | ~O_pla_ands[i][9]);
	end
endgenerate

generate
	for(i = 0; i < 8; i = i + 1) begin
		assign O_out[i] =
			(O_pla_ors[i][0] & O_and_outs[0]) |
			(O_pla_ors[i][1] & O_and_outs[1]) |
			(O_pla_ors[i][2] & O_and_outs[2]) |
			(O_pla_ors[i][3] & O_and_outs[3]) |
			(O_pla_ors[i][4] & O_and_outs[4]) |
			(O_pla_ors[i][5] & O_and_outs[5]) |
			(O_pla_ors[i][6] & O_and_outs[6]) |
			(O_pla_ors[i][7] & O_and_outs[7]) |
			(O_pla_ors[i][8] & O_and_outs[8]) |
			(O_pla_ors[i][9] & O_and_outs[9]) |
			(O_pla_ors[i][10] & O_and_outs[10]) |
			(O_pla_ors[i][11] & O_and_outs[11]) |
			(O_pla_ors[i][12] & O_and_outs[12]) |
			(O_pla_ors[i][13] & O_and_outs[13]) |
			(O_pla_ors[i][14] & O_and_outs[14]) |
			(O_pla_ors[i][15] & O_and_outs[15]) |
			(O_pla_ors[i][16] & O_and_outs[16]) |
			(O_pla_ors[i][17] & O_and_outs[17]) |
			(O_pla_ors[i][18] & O_and_outs[18]) |
			(O_pla_ors[i][19] & O_and_outs[19]);
	end
endgenerate

/*#endregion*/

/* Instruction decoding */

/*#region PLA*/

wire [15:0] pla_ins = {
	ins_in[7],
	~ins_in[7],
	ins_in[6],
	~ins_in[6],
	ins_in[5],
	~ins_in[5],
	ins_in[4],
	~ins_in[4],
	ins_in[3],
	~ins_in[3],
	ins_in[2],
	~ins_in[2],
	ins_in[1],
	~ins_in[1],
	ins_in[0],
	~ins_in[0]
};

wire [29:0] ins_and_outs;
generate
	for(i = 0; i < 30; i = i + 1) begin
		assign ins_and_outs[i] =
			(pla_ins[0] | ~ins_pla_ands[i][0]) &
			(pla_ins[1] | ~ins_pla_ands[i][1]) &
			(pla_ins[2] | ~ins_pla_ands[i][2]) &
			(pla_ins[3] | ~ins_pla_ands[i][3]) &
			(pla_ins[4] | ~ins_pla_ands[i][4]) &
			(pla_ins[5] | ~ins_pla_ands[i][5]) &
			(pla_ins[6] | ~ins_pla_ands[i][6]) &
			(pla_ins[7] | ~ins_pla_ands[i][7]) &
			(pla_ins[8] | ~ins_pla_ands[i][8]) &
			(pla_ins[9] | ~ins_pla_ands[i][9]) &
			(pla_ins[10] | ~ins_pla_ands[i][10]) &
			(pla_ins[11] | ~ins_pla_ands[i][11]) &
			(pla_ins[12] | ~ins_pla_ands[i][12]) &
			(pla_ins[13] | ~ins_pla_ands[i][13]) &
			(pla_ins[14] | ~ins_pla_ands[i][14]) &
			(pla_ins[15] | ~ins_pla_ands[i][15]);
	end
endgenerate

wire [15:0] ins_or_outs;
generate
	for(i = 0; i < 16; i = i + 1) begin
		assign ins_or_outs[i] =
			(ins_pla_ors[i][0] & ins_and_outs[0]) |
			(ins_pla_ors[i][1] & ins_and_outs[1]) |
			(ins_pla_ors[i][2] & ins_and_outs[2]) |
			(ins_pla_ors[i][3] & ins_and_outs[3]) |
			(ins_pla_ors[i][4] & ins_and_outs[4]) |
			(ins_pla_ors[i][5] & ins_and_outs[5]) |
			(ins_pla_ors[i][6] & ins_and_outs[6]) |
			(ins_pla_ors[i][7] & ins_and_outs[7]) |
			(ins_pla_ors[i][8] & ins_and_outs[8]) |
			(ins_pla_ors[i][9] & ins_and_outs[9]) |
			(ins_pla_ors[i][10] & ins_and_outs[10]) |
			(ins_pla_ors[i][11] & ins_and_outs[11]) |
			(ins_pla_ors[i][12] & ins_and_outs[12]) |
			(ins_pla_ors[i][13] & ins_and_outs[13]) |
			(ins_pla_ors[i][14] & ins_and_outs[14]) |
			(ins_pla_ors[i][15] & ins_and_outs[15]) |
			(ins_pla_ors[i][16] & ins_and_outs[16]) |
			(ins_pla_ors[i][17] & ins_and_outs[17]) |
			(ins_pla_ors[i][18] & ins_and_outs[18]) |
			(ins_pla_ors[i][19] & ins_and_outs[19]) |
			(ins_pla_ors[i][20] & ins_and_outs[20]) |
			(ins_pla_ors[i][21] & ins_and_outs[21]) |
			(ins_pla_ors[i][22] & ins_and_outs[22]) |
			(ins_pla_ors[i][23] & ins_and_outs[23]) |
			(ins_pla_ors[i][24] & ins_and_outs[24]) |
			(ins_pla_ors[i][25] & ins_and_outs[25]) |
			(ins_pla_ors[i][26] & ins_and_outs[26]) |
			(ins_pla_ors[i][27] & ins_and_outs[27]) |
			(ins_pla_ors[i][28] & ins_and_outs[28]) |
			(ins_pla_ors[i][29] & ins_and_outs[29]);
	end
endgenerate

/*#endregion*/

wire BR		= ins_in[7:6]	== 'b10;
wire CALL	= ins_in[7:6]	== 'b11;
wire CLOC	= ins_in		== 'b00001011;
wire COMX1	= ins_in		== 'b00000000;
wire COMX2	= ins_in		== 'b00001001;
wire LDP	= ins_in[7:4]	== 'b0001;
wire LDX1	= ins_in[7:2]	== 'b001111;
wire LDX2   = ins_in[7:3]   == 'b00101;
wire RBIT	= ins_in[7:2]	== 'b001101;
wire RETN	= ins_in		== 'b00001111;
wire RSTR	= ins_in		== 'b00001100;
wire SBIT	= ins_in[7:2]	== 'b001100;
wire SETR	= ins_in		== 'b00001101;
wire TDO	= ins_in		== 'b00001010;
wire LDX = chip_sel ? LDX2 : LDX1;
wire CLO = !chip_sel && CLOC;
wire COMC = chip_sel && CLOC;
wire COMX = chip_sel ? COMX2 : COMX1;

wire is_fixed = ins_and_outs == 0;

wire STO		=  ins_or_outs[ 0] & ~is_fixed;
wire CKM		=  ins_or_outs[ 1] & ~is_fixed;
wire CKP		= ~ins_or_outs[ 2] & ~is_fixed;
wire YTP		= ~ins_or_outs[ 3] & ~is_fixed;
wire MTP		= ~ins_or_outs[ 4] & ~is_fixed;
wire ATN		= ~ins_or_outs[ 5] & ~is_fixed;
wire NATN		= ~ins_or_outs[ 6] & ~is_fixed;
wire MTN		= ~ins_or_outs[ 7] & ~is_fixed;
wire FIFTEENTN	= ~ins_or_outs[ 8] & ~is_fixed;
wire CKN		= ~ins_or_outs[ 9] & ~is_fixed;
wire NE			=  ins_or_outs[10] & ~is_fixed;
wire C8			=  ins_or_outs[11] & ~is_fixed;
wire CIN		= ~ins_or_outs[12] & ~is_fixed;
wire AUTA		=  ins_or_outs[13] & ~is_fixed;
wire AUTY		=  ins_or_outs[14] & ~is_fixed;
wire STSL		=  ins_or_outs[15] & ~is_fixed;

/* End instruction decoding */

/* Clock phases + PC update */
wire [5:0] next_pc = { PC[4:0], (~((PC[5] ^ PC[4]) | (PC == 6'b111111))) | (PC == 6'h1F) };
wire phi_one = cycle == 0 || cycle == 1;
wire phi_two = cycle == 3 || cycle == 4;
wire phi_five = cycle == 2;
wire phi_three = cycle == 1 || cycle == 2 || cycle == 3;

/* Memory interface */
reg [10:0] rom_addr_buff;
wire [10:0] rom_addr_new = {CA, PA, PC};
assign rom_addr = rom_addr_buff;

reg [6:0] ram_addr_buff;
wire [6:0] ram_addr_new = {X, Y};
reg [3:0] ram_wval;
wire ram_cycle = phi_five && (STO || CKM || RBIT || SBIT);

assign ram_addr = ram_addr_buff;
assign ram_we = ram_cycle;
assign ram_val_out = ram_wval;

/* ALU */
wire [4:0] adder_res = P + N + (CIN ? 1 : 0);
wire [3:0] alu_res = adder_res[3:0];
wire next_carry = adder_res[4];
wire comp_out = P == N;
wire alu_new_status = (NE ? ~comp_out : 1) & (C8 ? next_carry : 1);

/* CKI bus */
wire [1:0] B = ins_arg[7:6];
wire [3:0] bmask = (B == 0 ? 'b1110 : (B == 1 ? 'b1101 : (B == 2 ? 'b1011 : 'b0111)));
wire [3:0] CKI_bus = (ins_in <= 'h07 || (ins_in[7:4] >= 'h4 && ins_in[7:4] <= 'h7)) ? ins_arg[7:4] : ((ins_in >= 'h08 && ins_in <= 'h0F) ? K_latch : (ins_in >= 'h30 && ins_in <= 'h3B) ? bmask : 0);

/* Wishbone stuff */
reg wb_step_state;

reg[29:0] pla_read;
assign pla_val_out = {2'b00, pla_read};
always @(pla_addr) begin
	case(pla_addr[6:5])
	0: pla_read <= {14'b0, ins_pla_ands[pla_addr[4:0]]};
	1: pla_read <= ins_pla_ors[pla_addr[3:0]];
	2: pla_read <= {20'b0, O_pla_ands[pla_addr[4:0]]};
	3: pla_read <= {10'b0, O_pla_ors[pla_addr[2:0]]};
	endcase
end

always @(posedge clk) begin
	K_latch <= K_in;
	if(reset) begin
		PA <= 15;
		PB <= 15;
		status <= 1;
		O_latch <= 0;
		R_latch <= 0;
		cycle <= 0;
		PC <= 0;
		CA <= 0;
		CS <= 0;
		CB <= 0;
		Y <= 0;
		X <= 0;
		CL <= 0;
		SL <= 1;
		wb_step_state <= 0;
		chip_sel <= chip_sel_i;
		ins_in <= 'h23; //TYA instruction. Something harmless to have as the first instruction.

		if(pla_override) begin
			if(pla_write) begin
				case(pla_addr[6:5])
				0: begin
					ins_pla_ands[pla_addr[4:0]] = pla_val_in[15:0];
				end
				1: begin
					ins_pla_ors[pla_addr[3:0]] = pla_val_in[29:0];
				end
				2: begin
					O_pla_ands[pla_addr[4:0]] = pla_val_in[9:0];
				end
				3: begin
					O_pla_ors[pla_addr[2:0]] = pla_val_in[19:0];
				end
				endcase
			end
		end else begin 
			if(chip_sel) begin

				/*#region default_ins_pla_1100*/

				ins_pla_ands[ 0] <= 'b0110101010101010;
				ins_pla_ands[ 1] <= 'b0110101000000000;
				ins_pla_ands[ 2] <= 'b0110100100000000;
				ins_pla_ands[ 3] <= 'b0110011000000000;
				ins_pla_ands[ 4] <= 'b0110010100000000;
				ins_pla_ands[ 5] <= 'b0101101010101010;
				ins_pla_ands[ 6] <= 'b0101101010101001;
				ins_pla_ands[ 7] <= 'b0101101010100110;
				ins_pla_ands[ 8] <= 'b0101101010100101;
				ins_pla_ands[ 9] <= 'b0101101010010000;
				ins_pla_ands[10] <= 'b0101100101101010;
				ins_pla_ands[11] <= 'b0101100101101001;
				ins_pla_ands[12] <= 'b0101100101100100;
				ins_pla_ands[13] <= 'b0101100101011010;
				ins_pla_ands[14] <= 'b0101100101011001;
				ins_pla_ands[15] <= 'b0101100101010110;
				ins_pla_ands[16] <= 'b0101100101010101;
				ins_pla_ands[17] <= 'b0101010110101001;
				ins_pla_ands[18] <= 'b0101010110010101;
				ins_pla_ands[19] <= 'b0101010101101010;
				ins_pla_ands[20] <= 'b0101010101101001;
				ins_pla_ands[21] <= 'b0101000101100110;
				ins_pla_ands[22] <= 'b0101000101100101;
				ins_pla_ands[23] <= 'b0101010101011010;
				ins_pla_ands[24] <= 'b0101010101011001;
				ins_pla_ands[25] <= 'b0101010101010110;
				ins_pla_ands[26] <= 'b0101010101010101;
				ins_pla_ands[27] <= 'b0000000000000000;
				ins_pla_ands[28] <= 'b0000000000000000;
				ins_pla_ands[29] <= 'b0000000000000000;

				ins_pla_ors[ 0] <= 'b000000100000000001110000000000;
				ins_pla_ors[ 1] <= 'b000000000000000000000000000100;
				ins_pla_ors[ 2] <= 'b000111111110011111110111101100;
				ins_pla_ors[ 3] <= 'b000110100111111100111111110011;
				ins_pla_ors[ 4] <= 'b000001011001110011110010011111;
				ins_pla_ors[ 5] <= 'b000010111011101111111111111101;
				ins_pla_ors[ 6] <= 'b000101111111111111111001111111;
				ins_pla_ors[ 7] <= 'b000111111111111111111111111111;
				ins_pla_ors[ 8] <= 'b000111101101111110111111111111;
				ins_pla_ors[ 9] <= 'b000111111111111111110111110111;
				ins_pla_ors[10] <= 'b000101000000100000001000101000;
				ins_pla_ors[11] <= 'b000010011110000001000111000011;
				ins_pla_ors[12] <= 'b000101110111111110111000111000;
				ins_pla_ors[13] <= 'b000000100111001010100111000011;
				ins_pla_ors[14] <= 'b000000011000010101000000010100;
				ins_pla_ors[15] <= 'b000001000000000000000000000000;

				/*#endregion*/

			end else begin

				/*#region default_ins_pla_1000*/

				ins_pla_ands[ 0] <= 'b0101010110101001;
				ins_pla_ands[ 1] <= 'b0101010110010110;
				ins_pla_ands[ 2] <= 'b0101010110010101;
				ins_pla_ands[ 3] <= 'b0101010101101010;
				ins_pla_ands[ 4] <= 'b0101010101101001;
				ins_pla_ands[ 5] <= 'b0101010101100101;
				ins_pla_ands[ 6] <= 'b0101010101011010;
				ins_pla_ands[ 7] <= 'b0101010101011001;
				ins_pla_ands[ 8] <= 'b0101010101000110;
				ins_pla_ands[ 9] <= 'b0101101010010000;
				ins_pla_ands[10] <= 'b0101100110101010;
				ins_pla_ands[11] <= 'b0101100110101001;
				ins_pla_ands[12] <= 'b0101100110100110;
				ins_pla_ands[13] <= 'b0101100110100101;
				ins_pla_ands[14] <= 'b0101100110011010;
				ins_pla_ands[15] <= 'b0101100110011001;
				ins_pla_ands[16] <= 'b0101100110010110;
				ins_pla_ands[17] <= 'b0101100110010101;
				ins_pla_ands[18] <= 'b0101100101101010;
				ins_pla_ands[19] <= 'b0101100101101001;
				ins_pla_ands[20] <= 'b0101100101100110;
				ins_pla_ands[21] <= 'b0101100101100101;
				ins_pla_ands[22] <= 'b0101100101011010;
				ins_pla_ands[23] <= 'b0101100101011001;
				ins_pla_ands[24] <= 'b0101100101010110;
				ins_pla_ands[25] <= 'b0101100101010101;
				ins_pla_ands[26] <= 'b0110101000000000;
				ins_pla_ands[27] <= 'b0110100100000000;
				ins_pla_ands[28] <= 'b0110011000000000;
				ins_pla_ands[29] <= 'b0110010100000000;

				ins_pla_ors[ 0] <= 'b000010000000000000100001100000;
				ins_pla_ors[ 1] <= 'b001000000000000000000000000000;
				ins_pla_ors[ 2] <= 'b011011111111111111110011100001;
				ins_pla_ors[ 3] <= 'b100101101111111001111101111111;
				ins_pla_ors[ 4] <= 'b111110011000000111010111111111;
				ins_pla_ors[ 5] <= 'b111111110011111111111001100110;
				ins_pla_ors[ 6] <= 'b111011111110101110111111111111;
				ins_pla_ors[ 7] <= 'b111111111111111111111111111111;
				ins_pla_ors[ 8] <= 'b111111111111110101111111111111;
				ins_pla_ors[ 9] <= 'b101111111111111111110111111111;
				ins_pla_ors[10] <= 'b010000000010000000001010000010;
				ins_pla_ors[11] <= 'b000100000101111111000100011000;
				ins_pla_ors[12] <= 'b110001111110001010111111110110;
				ins_pla_ors[13] <= 'b000001010101101001110100111101;
				ins_pla_ors[14] <= 'b101010101000000110000000000000;
				ins_pla_ors[15] <= 'b000000000000000000000010000000;

				/*#endregion*/

			end
			
			/*#region default_O_pla*/
			
			O_pla_ands[ 0] <= 'b1001010101;
			O_pla_ands[ 1] <= 'b1001010110;
			O_pla_ands[ 2] <= 'b1001011001;
			O_pla_ands[ 3] <= 'b1001011010;
			O_pla_ands[ 4] <= 'b1001100101;
			O_pla_ands[ 5] <= 'b1001100110;
			O_pla_ands[ 6] <= 'b1001101001;
			O_pla_ands[ 7] <= 'b1001101010;
			O_pla_ands[ 8] <= 'b1010010101;
			O_pla_ands[ 9] <= 'b1010010110;
			O_pla_ands[10] <= 'b1010011001;
			O_pla_ands[11] <= 'b1010011010;
			O_pla_ands[12] <= 'b1010100101;
			O_pla_ands[13] <= 'b1010100110;
			O_pla_ands[14] <= 'b1010101001;
			O_pla_ands[15] <= 'b1010101010;
			O_pla_ands[16] <= 'b0100000010;
			O_pla_ands[17] <= 'b0100001000;
			O_pla_ands[18] <= 'b0100100000;
			O_pla_ands[19] <= 'b0110000000;
			
			O_pla_ors[0] <= 'b00010000000000000000;
			O_pla_ors[1] <= 'b00101101011111101101;
			O_pla_ors[2] <= 'b01000010011110011111;
			O_pla_ors[3] <= 'b10000010111111111011;
			O_pla_ors[4] <= 'b00000111101101101101;
			O_pla_ors[5] <= 'b00001111110101000101;
			O_pla_ors[6] <= 'b00001101111101110001;
			O_pla_ors[7] <= 'b00001110111101111100;
			
			/*#endregion*/
		end
	end else if(!wb_override || (wb_step != wb_step_state)) begin
		wb_step_state <= wb_step;
		cycle <= cycle + 1;
		if(cycle == 5) begin
			//Execute BR/CALL
			if(BR) begin
				if(status) begin
					PC <= ins_in[5:0];
					if(!CL) begin
						PA <= PB;
						CA <= chip_sel ? CB : 0;
					end
				end
			end
			if(CALL) begin
				if(status) begin
					PC <= ins_in[5:0];
					if(CL) begin
						PB <= PA;
					end else begin
						SR <= PC;
						PB <= PA;
						PA <= PB;
						CA <= chip_sel ? CB : 0;
						CS <= chip_sel ? CA : 0;
						CL <= 1;
					end
				end
			end
			if(RETN) begin
				PA <= PB;
				if(CL) begin
					PC <= SR;
                    CA <= chip_sel ? CS : 0;
					CL <= 0;
				end
			end
			cycle <= 0;
		end
		if(phi_one) begin
			//Set ROM addr, K valid
			rom_addr_buff <= rom_addr_new;
			if(cycle == 0) begin
				//Read RAM + ALU input
				P <= (YTP ? Y : 0) | (MTP ? ram_val_in : 0) | (CKP ? CKI_bus : 0);
				N <= (ATN ? A : 0) | (NATN ? ~A : 0) | (MTN ? ram_val_in : 0) | (FIFTEENTN ? 15 : 0) | (CKN ? CKI_bus : 0);
			end
		end
		if(phi_two) begin
			if(cycle == 3) begin
				//Register store
				if(AUTA) begin
					A <= alu_res;
				end
				if(AUTY) begin
					Y <= alu_res;
				end
				status <= alu_new_status;
				if(STSL) begin
					SL <= alu_new_status;
				end
				if(CLO) begin
					O_latch <= 0;
					SL <= 0;
				end
				if(COMX) begin
					if(chip_sel) begin
						X[2] <= ~X[2];
					end else begin
						X[1:0] <= ~X[1:0];
						X[2] <= 0;
					end
				end
				if(LDX) begin
					if(chip_sel) begin
						X <= ins_arg[7:5];
					end else begin
						X[1:0] <= ins_arg[7:6];
						X[2] <= 0;
					end
				end
				if(SETR) begin
					R_latch[Y] <= 1;
				end
				if(RSTR) begin
					R_latch[Y] <= 0;
				end
				if(TDO) begin
					O_latch <= {SL, A};
				end
				if(LDP) begin
					PB <= ins_arg[7:4];
				end
				if(COMC) begin
					CB <= ~CB;
				end
			end else if(cycle == 4) begin
				//Instruction fetch + setup RAM address
				ins_in <= rom_value;
				PC <= next_pc;
				ram_addr_buff <= ram_addr_new;
			end
		end
		ram_wval <= (STO ? A : 0) | (CKM ? CKI_bus : 0) | (RBIT ? (ram_val_in & bmask) : 0) | (SBIT ? (ram_val_in | ~bmask) : 0);
	end
end

endmodule
