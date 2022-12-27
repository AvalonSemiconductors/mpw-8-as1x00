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

    /* Wishbone overrides & debug signals */
    input wb_override,
    input wb_step,
    output status_d,
    output [2:0] X_d,
    input pla_override, //Enable PLA override to set custom PLA values
    input [31:0] pla_val, //Value to be written into selected PLA register
    input [6:0] pla_addr, //Address for writing PLA regs. Format: RRAAAAA, R=Array addr, A=Value index
    input pla_write //Write enable for PLA. Once activated, PLA override is activated. Default values are no longer loaded on reset. Signal must be held high to persist custom PLA values.
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

wire [19:0] O_and_outs = {
    (O_pla_ins[0] | ~O_pla_ands[19][0]) &
        (O_pla_ins[1] | ~O_pla_ands[19][1]) &
        (O_pla_ins[2] | ~O_pla_ands[19][2]) &
        (O_pla_ins[3] | ~O_pla_ands[19][3]) &
        (O_pla_ins[4] | ~O_pla_ands[19][4]) &
        (O_pla_ins[5] | ~O_pla_ands[19][5]) &
        (O_pla_ins[6] | ~O_pla_ands[19][6]) &
        (O_pla_ins[7] | ~O_pla_ands[19][7]) &
        (O_pla_ins[8] | ~O_pla_ands[19][8]) &
        (O_pla_ins[9] | ~O_pla_ands[19][9]),
    (O_pla_ins[0] | ~O_pla_ands[18][0]) &
        (O_pla_ins[1] | ~O_pla_ands[18][1]) &
        (O_pla_ins[2] | ~O_pla_ands[18][2]) &
        (O_pla_ins[3] | ~O_pla_ands[18][3]) &
        (O_pla_ins[4] | ~O_pla_ands[18][4]) &
        (O_pla_ins[5] | ~O_pla_ands[18][5]) &
        (O_pla_ins[6] | ~O_pla_ands[18][6]) &
        (O_pla_ins[7] | ~O_pla_ands[18][7]) &
        (O_pla_ins[8] | ~O_pla_ands[18][8]) &
        (O_pla_ins[9] | ~O_pla_ands[18][9]),
    (O_pla_ins[0] | ~O_pla_ands[17][0]) &
        (O_pla_ins[1] | ~O_pla_ands[17][1]) &
        (O_pla_ins[2] | ~O_pla_ands[17][2]) &
        (O_pla_ins[3] | ~O_pla_ands[17][3]) &
        (O_pla_ins[4] | ~O_pla_ands[17][4]) &
        (O_pla_ins[5] | ~O_pla_ands[17][5]) &
        (O_pla_ins[6] | ~O_pla_ands[17][6]) &
        (O_pla_ins[7] | ~O_pla_ands[17][7]) &
        (O_pla_ins[8] | ~O_pla_ands[17][8]) &
        (O_pla_ins[9] | ~O_pla_ands[17][9]),
    (O_pla_ins[0] | ~O_pla_ands[16][0]) &
        (O_pla_ins[1] | ~O_pla_ands[16][1]) &
        (O_pla_ins[2] | ~O_pla_ands[16][2]) &
        (O_pla_ins[3] | ~O_pla_ands[16][3]) &
        (O_pla_ins[4] | ~O_pla_ands[16][4]) &
        (O_pla_ins[5] | ~O_pla_ands[16][5]) &
        (O_pla_ins[6] | ~O_pla_ands[16][6]) &
        (O_pla_ins[7] | ~O_pla_ands[16][7]) &
        (O_pla_ins[8] | ~O_pla_ands[16][8]) &
        (O_pla_ins[9] | ~O_pla_ands[16][9]),
    (O_pla_ins[0] | ~O_pla_ands[15][0]) &
        (O_pla_ins[1] | ~O_pla_ands[15][1]) &
        (O_pla_ins[2] | ~O_pla_ands[15][2]) &
        (O_pla_ins[3] | ~O_pla_ands[15][3]) &
        (O_pla_ins[4] | ~O_pla_ands[15][4]) &
        (O_pla_ins[5] | ~O_pla_ands[15][5]) &
        (O_pla_ins[6] | ~O_pla_ands[15][6]) &
        (O_pla_ins[7] | ~O_pla_ands[15][7]) &
        (O_pla_ins[8] | ~O_pla_ands[15][8]) &
        (O_pla_ins[9] | ~O_pla_ands[15][9]),
    (O_pla_ins[0] | ~O_pla_ands[14][0]) &
        (O_pla_ins[1] | ~O_pla_ands[14][1]) &
        (O_pla_ins[2] | ~O_pla_ands[14][2]) &
        (O_pla_ins[3] | ~O_pla_ands[14][3]) &
        (O_pla_ins[4] | ~O_pla_ands[14][4]) &
        (O_pla_ins[5] | ~O_pla_ands[14][5]) &
        (O_pla_ins[6] | ~O_pla_ands[14][6]) &
        (O_pla_ins[7] | ~O_pla_ands[14][7]) &
        (O_pla_ins[8] | ~O_pla_ands[14][8]) &
        (O_pla_ins[9] | ~O_pla_ands[14][9]),
    (O_pla_ins[0] | ~O_pla_ands[13][0]) &
        (O_pla_ins[1] | ~O_pla_ands[13][1]) &
        (O_pla_ins[2] | ~O_pla_ands[13][2]) &
        (O_pla_ins[3] | ~O_pla_ands[13][3]) &
        (O_pla_ins[4] | ~O_pla_ands[13][4]) &
        (O_pla_ins[5] | ~O_pla_ands[13][5]) &
        (O_pla_ins[6] | ~O_pla_ands[13][6]) &
        (O_pla_ins[7] | ~O_pla_ands[13][7]) &
        (O_pla_ins[8] | ~O_pla_ands[13][8]) &
        (O_pla_ins[9] | ~O_pla_ands[13][9]),
    (O_pla_ins[0] | ~O_pla_ands[12][0]) &
        (O_pla_ins[1] | ~O_pla_ands[12][1]) &
        (O_pla_ins[2] | ~O_pla_ands[12][2]) &
        (O_pla_ins[3] | ~O_pla_ands[12][3]) &
        (O_pla_ins[4] | ~O_pla_ands[12][4]) &
        (O_pla_ins[5] | ~O_pla_ands[12][5]) &
        (O_pla_ins[6] | ~O_pla_ands[12][6]) &
        (O_pla_ins[7] | ~O_pla_ands[12][7]) &
        (O_pla_ins[8] | ~O_pla_ands[12][8]) &
        (O_pla_ins[9] | ~O_pla_ands[12][9]),
    (O_pla_ins[0] | ~O_pla_ands[11][0]) &
        (O_pla_ins[1] | ~O_pla_ands[11][1]) &
        (O_pla_ins[2] | ~O_pla_ands[11][2]) &
        (O_pla_ins[3] | ~O_pla_ands[11][3]) &
        (O_pla_ins[4] | ~O_pla_ands[11][4]) &
        (O_pla_ins[5] | ~O_pla_ands[11][5]) &
        (O_pla_ins[6] | ~O_pla_ands[11][6]) &
        (O_pla_ins[7] | ~O_pla_ands[11][7]) &
        (O_pla_ins[8] | ~O_pla_ands[11][8]) &
        (O_pla_ins[9] | ~O_pla_ands[11][9]),
    (O_pla_ins[0] | ~O_pla_ands[10][0]) &
        (O_pla_ins[1] | ~O_pla_ands[10][1]) &
        (O_pla_ins[2] | ~O_pla_ands[10][2]) &
        (O_pla_ins[3] | ~O_pla_ands[10][3]) &
        (O_pla_ins[4] | ~O_pla_ands[10][4]) &
        (O_pla_ins[5] | ~O_pla_ands[10][5]) &
        (O_pla_ins[6] | ~O_pla_ands[10][6]) &
        (O_pla_ins[7] | ~O_pla_ands[10][7]) &
        (O_pla_ins[8] | ~O_pla_ands[10][8]) &
        (O_pla_ins[9] | ~O_pla_ands[10][9]),
    (O_pla_ins[0] | ~O_pla_ands[9][0]) &
        (O_pla_ins[1] | ~O_pla_ands[9][1]) &
        (O_pla_ins[2] | ~O_pla_ands[9][2]) &
        (O_pla_ins[3] | ~O_pla_ands[9][3]) &
        (O_pla_ins[4] | ~O_pla_ands[9][4]) &
        (O_pla_ins[5] | ~O_pla_ands[9][5]) &
        (O_pla_ins[6] | ~O_pla_ands[9][6]) &
        (O_pla_ins[7] | ~O_pla_ands[9][7]) &
        (O_pla_ins[8] | ~O_pla_ands[9][8]) &
        (O_pla_ins[9] | ~O_pla_ands[9][9]),
    (O_pla_ins[0] | ~O_pla_ands[8][0]) &
        (O_pla_ins[1] | ~O_pla_ands[8][1]) &
        (O_pla_ins[2] | ~O_pla_ands[8][2]) &
        (O_pla_ins[3] | ~O_pla_ands[8][3]) &
        (O_pla_ins[4] | ~O_pla_ands[8][4]) &
        (O_pla_ins[5] | ~O_pla_ands[8][5]) &
        (O_pla_ins[6] | ~O_pla_ands[8][6]) &
        (O_pla_ins[7] | ~O_pla_ands[8][7]) &
        (O_pla_ins[8] | ~O_pla_ands[8][8]) &
        (O_pla_ins[9] | ~O_pla_ands[8][9]),
    (O_pla_ins[0] | ~O_pla_ands[7][0]) &
        (O_pla_ins[1] | ~O_pla_ands[7][1]) &
        (O_pla_ins[2] | ~O_pla_ands[7][2]) &
        (O_pla_ins[3] | ~O_pla_ands[7][3]) &
        (O_pla_ins[4] | ~O_pla_ands[7][4]) &
        (O_pla_ins[5] | ~O_pla_ands[7][5]) &
        (O_pla_ins[6] | ~O_pla_ands[7][6]) &
        (O_pla_ins[7] | ~O_pla_ands[7][7]) &
        (O_pla_ins[8] | ~O_pla_ands[7][8]) &
        (O_pla_ins[9] | ~O_pla_ands[7][9]),
    (O_pla_ins[0] | ~O_pla_ands[6][0]) &
        (O_pla_ins[1] | ~O_pla_ands[6][1]) &
        (O_pla_ins[2] | ~O_pla_ands[6][2]) &
        (O_pla_ins[3] | ~O_pla_ands[6][3]) &
        (O_pla_ins[4] | ~O_pla_ands[6][4]) &
        (O_pla_ins[5] | ~O_pla_ands[6][5]) &
        (O_pla_ins[6] | ~O_pla_ands[6][6]) &
        (O_pla_ins[7] | ~O_pla_ands[6][7]) &
        (O_pla_ins[8] | ~O_pla_ands[6][8]) &
        (O_pla_ins[9] | ~O_pla_ands[6][9]),
    (O_pla_ins[0] | ~O_pla_ands[5][0]) &
        (O_pla_ins[1] | ~O_pla_ands[5][1]) &
        (O_pla_ins[2] | ~O_pla_ands[5][2]) &
        (O_pla_ins[3] | ~O_pla_ands[5][3]) &
        (O_pla_ins[4] | ~O_pla_ands[5][4]) &
        (O_pla_ins[5] | ~O_pla_ands[5][5]) &
        (O_pla_ins[6] | ~O_pla_ands[5][6]) &
        (O_pla_ins[7] | ~O_pla_ands[5][7]) &
        (O_pla_ins[8] | ~O_pla_ands[5][8]) &
        (O_pla_ins[9] | ~O_pla_ands[5][9]),
    (O_pla_ins[0] | ~O_pla_ands[4][0]) &
        (O_pla_ins[1] | ~O_pla_ands[4][1]) &
        (O_pla_ins[2] | ~O_pla_ands[4][2]) &
        (O_pla_ins[3] | ~O_pla_ands[4][3]) &
        (O_pla_ins[4] | ~O_pla_ands[4][4]) &
        (O_pla_ins[5] | ~O_pla_ands[4][5]) &
        (O_pla_ins[6] | ~O_pla_ands[4][6]) &
        (O_pla_ins[7] | ~O_pla_ands[4][7]) &
        (O_pla_ins[8] | ~O_pla_ands[4][8]) &
        (O_pla_ins[9] | ~O_pla_ands[4][9]),
    (O_pla_ins[0] | ~O_pla_ands[3][0]) &
        (O_pla_ins[1] | ~O_pla_ands[3][1]) &
        (O_pla_ins[2] | ~O_pla_ands[3][2]) &
        (O_pla_ins[3] | ~O_pla_ands[3][3]) &
        (O_pla_ins[4] | ~O_pla_ands[3][4]) &
        (O_pla_ins[5] | ~O_pla_ands[3][5]) &
        (O_pla_ins[6] | ~O_pla_ands[3][6]) &
        (O_pla_ins[7] | ~O_pla_ands[3][7]) &
        (O_pla_ins[8] | ~O_pla_ands[3][8]) &
        (O_pla_ins[9] | ~O_pla_ands[3][9]),
    (O_pla_ins[0] | ~O_pla_ands[2][0]) &
        (O_pla_ins[1] | ~O_pla_ands[2][1]) &
        (O_pla_ins[2] | ~O_pla_ands[2][2]) &
        (O_pla_ins[3] | ~O_pla_ands[2][3]) &
        (O_pla_ins[4] | ~O_pla_ands[2][4]) &
        (O_pla_ins[5] | ~O_pla_ands[2][5]) &
        (O_pla_ins[6] | ~O_pla_ands[2][6]) &
        (O_pla_ins[7] | ~O_pla_ands[2][7]) &
        (O_pla_ins[8] | ~O_pla_ands[2][8]) &
        (O_pla_ins[9] | ~O_pla_ands[2][9]),
    (O_pla_ins[0] | ~O_pla_ands[1][0]) &
        (O_pla_ins[1] | ~O_pla_ands[1][1]) &
        (O_pla_ins[2] | ~O_pla_ands[1][2]) &
        (O_pla_ins[3] | ~O_pla_ands[1][3]) &
        (O_pla_ins[4] | ~O_pla_ands[1][4]) &
        (O_pla_ins[5] | ~O_pla_ands[1][5]) &
        (O_pla_ins[6] | ~O_pla_ands[1][6]) &
        (O_pla_ins[7] | ~O_pla_ands[1][7]) &
        (O_pla_ins[8] | ~O_pla_ands[1][8]) &
        (O_pla_ins[9] | ~O_pla_ands[1][9]),
    (O_pla_ins[0] | ~O_pla_ands[0][0]) &
        (O_pla_ins[1] | ~O_pla_ands[0][1]) &
        (O_pla_ins[2] | ~O_pla_ands[0][2]) &
        (O_pla_ins[3] | ~O_pla_ands[0][3]) &
        (O_pla_ins[4] | ~O_pla_ands[0][4]) &
        (O_pla_ins[5] | ~O_pla_ands[0][5]) &
        (O_pla_ins[6] | ~O_pla_ands[0][6]) &
        (O_pla_ins[7] | ~O_pla_ands[0][7]) &
        (O_pla_ins[8] | ~O_pla_ands[0][8]) &
        (O_pla_ins[9] | ~O_pla_ands[0][9])
};

wire [7:0] O_or_outs = {
    (O_pla_ors[7][0] & O_and_outs[0]) |
        (O_pla_ors[7][1] & O_and_outs[1]) |
        (O_pla_ors[7][2] & O_and_outs[2]) |
        (O_pla_ors[7][3] & O_and_outs[3]) |
        (O_pla_ors[7][4] & O_and_outs[4]) |
        (O_pla_ors[7][5] & O_and_outs[5]) |
        (O_pla_ors[7][6] & O_and_outs[6]) |
        (O_pla_ors[7][7] & O_and_outs[7]) |
        (O_pla_ors[7][8] & O_and_outs[8]) |
        (O_pla_ors[7][9] & O_and_outs[9]) |
        (O_pla_ors[7][10] & O_and_outs[10]) |
        (O_pla_ors[7][11] & O_and_outs[11]) |
        (O_pla_ors[7][12] & O_and_outs[12]) |
        (O_pla_ors[7][13] & O_and_outs[13]) |
        (O_pla_ors[7][14] & O_and_outs[14]) |
        (O_pla_ors[7][15] & O_and_outs[15]) |
        (O_pla_ors[7][16] & O_and_outs[16]) |
        (O_pla_ors[7][17] & O_and_outs[17]) |
        (O_pla_ors[7][18] & O_and_outs[18]) |
        (O_pla_ors[7][19] & O_and_outs[19]),
    (O_pla_ors[6][0] & O_and_outs[0]) |
        (O_pla_ors[6][1] & O_and_outs[1]) |
        (O_pla_ors[6][2] & O_and_outs[2]) |
        (O_pla_ors[6][3] & O_and_outs[3]) |
        (O_pla_ors[6][4] & O_and_outs[4]) |
        (O_pla_ors[6][5] & O_and_outs[5]) |
        (O_pla_ors[6][6] & O_and_outs[6]) |
        (O_pla_ors[6][7] & O_and_outs[7]) |
        (O_pla_ors[6][8] & O_and_outs[8]) |
        (O_pla_ors[6][9] & O_and_outs[9]) |
        (O_pla_ors[6][10] & O_and_outs[10]) |
        (O_pla_ors[6][11] & O_and_outs[11]) |
        (O_pla_ors[6][12] & O_and_outs[12]) |
        (O_pla_ors[6][13] & O_and_outs[13]) |
        (O_pla_ors[6][14] & O_and_outs[14]) |
        (O_pla_ors[6][15] & O_and_outs[15]) |
        (O_pla_ors[6][16] & O_and_outs[16]) |
        (O_pla_ors[6][17] & O_and_outs[17]) |
        (O_pla_ors[6][18] & O_and_outs[18]) |
        (O_pla_ors[6][19] & O_and_outs[19]),
    (O_pla_ors[5][0] & O_and_outs[0]) |
        (O_pla_ors[5][1] & O_and_outs[1]) |
        (O_pla_ors[5][2] & O_and_outs[2]) |
        (O_pla_ors[5][3] & O_and_outs[3]) |
        (O_pla_ors[5][4] & O_and_outs[4]) |
        (O_pla_ors[5][5] & O_and_outs[5]) |
        (O_pla_ors[5][6] & O_and_outs[6]) |
        (O_pla_ors[5][7] & O_and_outs[7]) |
        (O_pla_ors[5][8] & O_and_outs[8]) |
        (O_pla_ors[5][9] & O_and_outs[9]) |
        (O_pla_ors[5][10] & O_and_outs[10]) |
        (O_pla_ors[5][11] & O_and_outs[11]) |
        (O_pla_ors[5][12] & O_and_outs[12]) |
        (O_pla_ors[5][13] & O_and_outs[13]) |
        (O_pla_ors[5][14] & O_and_outs[14]) |
        (O_pla_ors[5][15] & O_and_outs[15]) |
        (O_pla_ors[5][16] & O_and_outs[16]) |
        (O_pla_ors[5][17] & O_and_outs[17]) |
        (O_pla_ors[5][18] & O_and_outs[18]) |
        (O_pla_ors[5][19] & O_and_outs[19]),
    (O_pla_ors[4][0] & O_and_outs[0]) |
        (O_pla_ors[4][1] & O_and_outs[1]) |
        (O_pla_ors[4][2] & O_and_outs[2]) |
        (O_pla_ors[4][3] & O_and_outs[3]) |
        (O_pla_ors[4][4] & O_and_outs[4]) |
        (O_pla_ors[4][5] & O_and_outs[5]) |
        (O_pla_ors[4][6] & O_and_outs[6]) |
        (O_pla_ors[4][7] & O_and_outs[7]) |
        (O_pla_ors[4][8] & O_and_outs[8]) |
        (O_pla_ors[4][9] & O_and_outs[9]) |
        (O_pla_ors[4][10] & O_and_outs[10]) |
        (O_pla_ors[4][11] & O_and_outs[11]) |
        (O_pla_ors[4][12] & O_and_outs[12]) |
        (O_pla_ors[4][13] & O_and_outs[13]) |
        (O_pla_ors[4][14] & O_and_outs[14]) |
        (O_pla_ors[4][15] & O_and_outs[15]) |
        (O_pla_ors[4][16] & O_and_outs[16]) |
        (O_pla_ors[4][17] & O_and_outs[17]) |
        (O_pla_ors[4][18] & O_and_outs[18]) |
        (O_pla_ors[4][19] & O_and_outs[19]),
    (O_pla_ors[3][0] & O_and_outs[0]) |
        (O_pla_ors[3][1] & O_and_outs[1]) |
        (O_pla_ors[3][2] & O_and_outs[2]) |
        (O_pla_ors[3][3] & O_and_outs[3]) |
        (O_pla_ors[3][4] & O_and_outs[4]) |
        (O_pla_ors[3][5] & O_and_outs[5]) |
        (O_pla_ors[3][6] & O_and_outs[6]) |
        (O_pla_ors[3][7] & O_and_outs[7]) |
        (O_pla_ors[3][8] & O_and_outs[8]) |
        (O_pla_ors[3][9] & O_and_outs[9]) |
        (O_pla_ors[3][10] & O_and_outs[10]) |
        (O_pla_ors[3][11] & O_and_outs[11]) |
        (O_pla_ors[3][12] & O_and_outs[12]) |
        (O_pla_ors[3][13] & O_and_outs[13]) |
        (O_pla_ors[3][14] & O_and_outs[14]) |
        (O_pla_ors[3][15] & O_and_outs[15]) |
        (O_pla_ors[3][16] & O_and_outs[16]) |
        (O_pla_ors[3][17] & O_and_outs[17]) |
        (O_pla_ors[3][18] & O_and_outs[18]) |
        (O_pla_ors[3][19] & O_and_outs[19]),
    (O_pla_ors[2][0] & O_and_outs[0]) |
        (O_pla_ors[2][1] & O_and_outs[1]) |
        (O_pla_ors[2][2] & O_and_outs[2]) |
        (O_pla_ors[2][3] & O_and_outs[3]) |
        (O_pla_ors[2][4] & O_and_outs[4]) |
        (O_pla_ors[2][5] & O_and_outs[5]) |
        (O_pla_ors[2][6] & O_and_outs[6]) |
        (O_pla_ors[2][7] & O_and_outs[7]) |
        (O_pla_ors[2][8] & O_and_outs[8]) |
        (O_pla_ors[2][9] & O_and_outs[9]) |
        (O_pla_ors[2][10] & O_and_outs[10]) |
        (O_pla_ors[2][11] & O_and_outs[11]) |
        (O_pla_ors[2][12] & O_and_outs[12]) |
        (O_pla_ors[2][13] & O_and_outs[13]) |
        (O_pla_ors[2][14] & O_and_outs[14]) |
        (O_pla_ors[2][15] & O_and_outs[15]) |
        (O_pla_ors[2][16] & O_and_outs[16]) |
        (O_pla_ors[2][17] & O_and_outs[17]) |
        (O_pla_ors[2][18] & O_and_outs[18]) |
        (O_pla_ors[2][19] & O_and_outs[19]),
    (O_pla_ors[1][0] & O_and_outs[0]) |
        (O_pla_ors[1][1] & O_and_outs[1]) |
        (O_pla_ors[1][2] & O_and_outs[2]) |
        (O_pla_ors[1][3] & O_and_outs[3]) |
        (O_pla_ors[1][4] & O_and_outs[4]) |
        (O_pla_ors[1][5] & O_and_outs[5]) |
        (O_pla_ors[1][6] & O_and_outs[6]) |
        (O_pla_ors[1][7] & O_and_outs[7]) |
        (O_pla_ors[1][8] & O_and_outs[8]) |
        (O_pla_ors[1][9] & O_and_outs[9]) |
        (O_pla_ors[1][10] & O_and_outs[10]) |
        (O_pla_ors[1][11] & O_and_outs[11]) |
        (O_pla_ors[1][12] & O_and_outs[12]) |
        (O_pla_ors[1][13] & O_and_outs[13]) |
        (O_pla_ors[1][14] & O_and_outs[14]) |
        (O_pla_ors[1][15] & O_and_outs[15]) |
        (O_pla_ors[1][16] & O_and_outs[16]) |
        (O_pla_ors[1][17] & O_and_outs[17]) |
        (O_pla_ors[1][18] & O_and_outs[18]) |
        (O_pla_ors[1][19] & O_and_outs[19]),
    (O_pla_ors[0][0] & O_and_outs[0]) |
        (O_pla_ors[0][1] & O_and_outs[1]) |
        (O_pla_ors[0][2] & O_and_outs[2]) |
        (O_pla_ors[0][3] & O_and_outs[3]) |
        (O_pla_ors[0][4] & O_and_outs[4]) |
        (O_pla_ors[0][5] & O_and_outs[5]) |
        (O_pla_ors[0][6] & O_and_outs[6]) |
        (O_pla_ors[0][7] & O_and_outs[7]) |
        (O_pla_ors[0][8] & O_and_outs[8]) |
        (O_pla_ors[0][9] & O_and_outs[9]) |
        (O_pla_ors[0][10] & O_and_outs[10]) |
        (O_pla_ors[0][11] & O_and_outs[11]) |
        (O_pla_ors[0][12] & O_and_outs[12]) |
        (O_pla_ors[0][13] & O_and_outs[13]) |
        (O_pla_ors[0][14] & O_and_outs[14]) |
        (O_pla_ors[0][15] & O_and_outs[15]) |
        (O_pla_ors[0][16] & O_and_outs[16]) |
        (O_pla_ors[0][17] & O_and_outs[17]) |
        (O_pla_ors[0][18] & O_and_outs[18]) |
        (O_pla_ors[0][19] & O_and_outs[19])
};
assign O_out = O_or_outs;

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

wire [29:0] ins_and_outs = {
    (pla_ins[0] | ~ins_pla_ands[29][0]) &
        (pla_ins[1] | ~ins_pla_ands[29][1]) &
        (pla_ins[2] | ~ins_pla_ands[29][2]) &
        (pla_ins[3] | ~ins_pla_ands[29][3]) &
        (pla_ins[4] | ~ins_pla_ands[29][4]) &
        (pla_ins[5] | ~ins_pla_ands[29][5]) &
        (pla_ins[6] | ~ins_pla_ands[29][6]) &
        (pla_ins[7] | ~ins_pla_ands[29][7]) &
        (pla_ins[8] | ~ins_pla_ands[29][8]) &
        (pla_ins[9] | ~ins_pla_ands[29][9]) &
        (pla_ins[10] | ~ins_pla_ands[29][10]) &
        (pla_ins[11] | ~ins_pla_ands[29][11]) &
        (pla_ins[12] | ~ins_pla_ands[29][12]) &
        (pla_ins[13] | ~ins_pla_ands[29][13]) &
        (pla_ins[14] | ~ins_pla_ands[29][14]) &
        (pla_ins[15] | ~ins_pla_ands[29][15]),
    (pla_ins[0] | ~ins_pla_ands[28][0]) &
        (pla_ins[1] | ~ins_pla_ands[28][1]) &
        (pla_ins[2] | ~ins_pla_ands[28][2]) &
        (pla_ins[3] | ~ins_pla_ands[28][3]) &
        (pla_ins[4] | ~ins_pla_ands[28][4]) &
        (pla_ins[5] | ~ins_pla_ands[28][5]) &
        (pla_ins[6] | ~ins_pla_ands[28][6]) &
        (pla_ins[7] | ~ins_pla_ands[28][7]) &
        (pla_ins[8] | ~ins_pla_ands[28][8]) &
        (pla_ins[9] | ~ins_pla_ands[28][9]) &
        (pla_ins[10] | ~ins_pla_ands[28][10]) &
        (pla_ins[11] | ~ins_pla_ands[28][11]) &
        (pla_ins[12] | ~ins_pla_ands[28][12]) &
        (pla_ins[13] | ~ins_pla_ands[28][13]) &
        (pla_ins[14] | ~ins_pla_ands[28][14]) &
        (pla_ins[15] | ~ins_pla_ands[28][15]),
    (pla_ins[0] | ~ins_pla_ands[27][0]) &
        (pla_ins[1] | ~ins_pla_ands[27][1]) &
        (pla_ins[2] | ~ins_pla_ands[27][2]) &
        (pla_ins[3] | ~ins_pla_ands[27][3]) &
        (pla_ins[4] | ~ins_pla_ands[27][4]) &
        (pla_ins[5] | ~ins_pla_ands[27][5]) &
        (pla_ins[6] | ~ins_pla_ands[27][6]) &
        (pla_ins[7] | ~ins_pla_ands[27][7]) &
        (pla_ins[8] | ~ins_pla_ands[27][8]) &
        (pla_ins[9] | ~ins_pla_ands[27][9]) &
        (pla_ins[10] | ~ins_pla_ands[27][10]) &
        (pla_ins[11] | ~ins_pla_ands[27][11]) &
        (pla_ins[12] | ~ins_pla_ands[27][12]) &
        (pla_ins[13] | ~ins_pla_ands[27][13]) &
        (pla_ins[14] | ~ins_pla_ands[27][14]) &
        (pla_ins[15] | ~ins_pla_ands[27][15]),
    (pla_ins[0] | ~ins_pla_ands[26][0]) &
        (pla_ins[1] | ~ins_pla_ands[26][1]) &
        (pla_ins[2] | ~ins_pla_ands[26][2]) &
        (pla_ins[3] | ~ins_pla_ands[26][3]) &
        (pla_ins[4] | ~ins_pla_ands[26][4]) &
        (pla_ins[5] | ~ins_pla_ands[26][5]) &
        (pla_ins[6] | ~ins_pla_ands[26][6]) &
        (pla_ins[7] | ~ins_pla_ands[26][7]) &
        (pla_ins[8] | ~ins_pla_ands[26][8]) &
        (pla_ins[9] | ~ins_pla_ands[26][9]) &
        (pla_ins[10] | ~ins_pla_ands[26][10]) &
        (pla_ins[11] | ~ins_pla_ands[26][11]) &
        (pla_ins[12] | ~ins_pla_ands[26][12]) &
        (pla_ins[13] | ~ins_pla_ands[26][13]) &
        (pla_ins[14] | ~ins_pla_ands[26][14]) &
        (pla_ins[15] | ~ins_pla_ands[26][15]),
    (pla_ins[0] | ~ins_pla_ands[25][0]) &
        (pla_ins[1] | ~ins_pla_ands[25][1]) &
        (pla_ins[2] | ~ins_pla_ands[25][2]) &
        (pla_ins[3] | ~ins_pla_ands[25][3]) &
        (pla_ins[4] | ~ins_pla_ands[25][4]) &
        (pla_ins[5] | ~ins_pla_ands[25][5]) &
        (pla_ins[6] | ~ins_pla_ands[25][6]) &
        (pla_ins[7] | ~ins_pla_ands[25][7]) &
        (pla_ins[8] | ~ins_pla_ands[25][8]) &
        (pla_ins[9] | ~ins_pla_ands[25][9]) &
        (pla_ins[10] | ~ins_pla_ands[25][10]) &
        (pla_ins[11] | ~ins_pla_ands[25][11]) &
        (pla_ins[12] | ~ins_pla_ands[25][12]) &
        (pla_ins[13] | ~ins_pla_ands[25][13]) &
        (pla_ins[14] | ~ins_pla_ands[25][14]) &
        (pla_ins[15] | ~ins_pla_ands[25][15]),
    (pla_ins[0] | ~ins_pla_ands[24][0]) &
        (pla_ins[1] | ~ins_pla_ands[24][1]) &
        (pla_ins[2] | ~ins_pla_ands[24][2]) &
        (pla_ins[3] | ~ins_pla_ands[24][3]) &
        (pla_ins[4] | ~ins_pla_ands[24][4]) &
        (pla_ins[5] | ~ins_pla_ands[24][5]) &
        (pla_ins[6] | ~ins_pla_ands[24][6]) &
        (pla_ins[7] | ~ins_pla_ands[24][7]) &
        (pla_ins[8] | ~ins_pla_ands[24][8]) &
        (pla_ins[9] | ~ins_pla_ands[24][9]) &
        (pla_ins[10] | ~ins_pla_ands[24][10]) &
        (pla_ins[11] | ~ins_pla_ands[24][11]) &
        (pla_ins[12] | ~ins_pla_ands[24][12]) &
        (pla_ins[13] | ~ins_pla_ands[24][13]) &
        (pla_ins[14] | ~ins_pla_ands[24][14]) &
        (pla_ins[15] | ~ins_pla_ands[24][15]),
    (pla_ins[0] | ~ins_pla_ands[23][0]) &
        (pla_ins[1] | ~ins_pla_ands[23][1]) &
        (pla_ins[2] | ~ins_pla_ands[23][2]) &
        (pla_ins[3] | ~ins_pla_ands[23][3]) &
        (pla_ins[4] | ~ins_pla_ands[23][4]) &
        (pla_ins[5] | ~ins_pla_ands[23][5]) &
        (pla_ins[6] | ~ins_pla_ands[23][6]) &
        (pla_ins[7] | ~ins_pla_ands[23][7]) &
        (pla_ins[8] | ~ins_pla_ands[23][8]) &
        (pla_ins[9] | ~ins_pla_ands[23][9]) &
        (pla_ins[10] | ~ins_pla_ands[23][10]) &
        (pla_ins[11] | ~ins_pla_ands[23][11]) &
        (pla_ins[12] | ~ins_pla_ands[23][12]) &
        (pla_ins[13] | ~ins_pla_ands[23][13]) &
        (pla_ins[14] | ~ins_pla_ands[23][14]) &
        (pla_ins[15] | ~ins_pla_ands[23][15]),
    (pla_ins[0] | ~ins_pla_ands[22][0]) &
        (pla_ins[1] | ~ins_pla_ands[22][1]) &
        (pla_ins[2] | ~ins_pla_ands[22][2]) &
        (pla_ins[3] | ~ins_pla_ands[22][3]) &
        (pla_ins[4] | ~ins_pla_ands[22][4]) &
        (pla_ins[5] | ~ins_pla_ands[22][5]) &
        (pla_ins[6] | ~ins_pla_ands[22][6]) &
        (pla_ins[7] | ~ins_pla_ands[22][7]) &
        (pla_ins[8] | ~ins_pla_ands[22][8]) &
        (pla_ins[9] | ~ins_pla_ands[22][9]) &
        (pla_ins[10] | ~ins_pla_ands[22][10]) &
        (pla_ins[11] | ~ins_pla_ands[22][11]) &
        (pla_ins[12] | ~ins_pla_ands[22][12]) &
        (pla_ins[13] | ~ins_pla_ands[22][13]) &
        (pla_ins[14] | ~ins_pla_ands[22][14]) &
        (pla_ins[15] | ~ins_pla_ands[22][15]),
    (pla_ins[0] | ~ins_pla_ands[21][0]) &
        (pla_ins[1] | ~ins_pla_ands[21][1]) &
        (pla_ins[2] | ~ins_pla_ands[21][2]) &
        (pla_ins[3] | ~ins_pla_ands[21][3]) &
        (pla_ins[4] | ~ins_pla_ands[21][4]) &
        (pla_ins[5] | ~ins_pla_ands[21][5]) &
        (pla_ins[6] | ~ins_pla_ands[21][6]) &
        (pla_ins[7] | ~ins_pla_ands[21][7]) &
        (pla_ins[8] | ~ins_pla_ands[21][8]) &
        (pla_ins[9] | ~ins_pla_ands[21][9]) &
        (pla_ins[10] | ~ins_pla_ands[21][10]) &
        (pla_ins[11] | ~ins_pla_ands[21][11]) &
        (pla_ins[12] | ~ins_pla_ands[21][12]) &
        (pla_ins[13] | ~ins_pla_ands[21][13]) &
        (pla_ins[14] | ~ins_pla_ands[21][14]) &
        (pla_ins[15] | ~ins_pla_ands[21][15]),
    (pla_ins[0] | ~ins_pla_ands[20][0]) &
        (pla_ins[1] | ~ins_pla_ands[20][1]) &
        (pla_ins[2] | ~ins_pla_ands[20][2]) &
        (pla_ins[3] | ~ins_pla_ands[20][3]) &
        (pla_ins[4] | ~ins_pla_ands[20][4]) &
        (pla_ins[5] | ~ins_pla_ands[20][5]) &
        (pla_ins[6] | ~ins_pla_ands[20][6]) &
        (pla_ins[7] | ~ins_pla_ands[20][7]) &
        (pla_ins[8] | ~ins_pla_ands[20][8]) &
        (pla_ins[9] | ~ins_pla_ands[20][9]) &
        (pla_ins[10] | ~ins_pla_ands[20][10]) &
        (pla_ins[11] | ~ins_pla_ands[20][11]) &
        (pla_ins[12] | ~ins_pla_ands[20][12]) &
        (pla_ins[13] | ~ins_pla_ands[20][13]) &
        (pla_ins[14] | ~ins_pla_ands[20][14]) &
        (pla_ins[15] | ~ins_pla_ands[20][15]),
    (pla_ins[0] | ~ins_pla_ands[19][0]) &
        (pla_ins[1] | ~ins_pla_ands[19][1]) &
        (pla_ins[2] | ~ins_pla_ands[19][2]) &
        (pla_ins[3] | ~ins_pla_ands[19][3]) &
        (pla_ins[4] | ~ins_pla_ands[19][4]) &
        (pla_ins[5] | ~ins_pla_ands[19][5]) &
        (pla_ins[6] | ~ins_pla_ands[19][6]) &
        (pla_ins[7] | ~ins_pla_ands[19][7]) &
        (pla_ins[8] | ~ins_pla_ands[19][8]) &
        (pla_ins[9] | ~ins_pla_ands[19][9]) &
        (pla_ins[10] | ~ins_pla_ands[19][10]) &
        (pla_ins[11] | ~ins_pla_ands[19][11]) &
        (pla_ins[12] | ~ins_pla_ands[19][12]) &
        (pla_ins[13] | ~ins_pla_ands[19][13]) &
        (pla_ins[14] | ~ins_pla_ands[19][14]) &
        (pla_ins[15] | ~ins_pla_ands[19][15]),
    (pla_ins[0] | ~ins_pla_ands[18][0]) &
        (pla_ins[1] | ~ins_pla_ands[18][1]) &
        (pla_ins[2] | ~ins_pla_ands[18][2]) &
        (pla_ins[3] | ~ins_pla_ands[18][3]) &
        (pla_ins[4] | ~ins_pla_ands[18][4]) &
        (pla_ins[5] | ~ins_pla_ands[18][5]) &
        (pla_ins[6] | ~ins_pla_ands[18][6]) &
        (pla_ins[7] | ~ins_pla_ands[18][7]) &
        (pla_ins[8] | ~ins_pla_ands[18][8]) &
        (pla_ins[9] | ~ins_pla_ands[18][9]) &
        (pla_ins[10] | ~ins_pla_ands[18][10]) &
        (pla_ins[11] | ~ins_pla_ands[18][11]) &
        (pla_ins[12] | ~ins_pla_ands[18][12]) &
        (pla_ins[13] | ~ins_pla_ands[18][13]) &
        (pla_ins[14] | ~ins_pla_ands[18][14]) &
        (pla_ins[15] | ~ins_pla_ands[18][15]),
    (pla_ins[0] | ~ins_pla_ands[17][0]) &
        (pla_ins[1] | ~ins_pla_ands[17][1]) &
        (pla_ins[2] | ~ins_pla_ands[17][2]) &
        (pla_ins[3] | ~ins_pla_ands[17][3]) &
        (pla_ins[4] | ~ins_pla_ands[17][4]) &
        (pla_ins[5] | ~ins_pla_ands[17][5]) &
        (pla_ins[6] | ~ins_pla_ands[17][6]) &
        (pla_ins[7] | ~ins_pla_ands[17][7]) &
        (pla_ins[8] | ~ins_pla_ands[17][8]) &
        (pla_ins[9] | ~ins_pla_ands[17][9]) &
        (pla_ins[10] | ~ins_pla_ands[17][10]) &
        (pla_ins[11] | ~ins_pla_ands[17][11]) &
        (pla_ins[12] | ~ins_pla_ands[17][12]) &
        (pla_ins[13] | ~ins_pla_ands[17][13]) &
        (pla_ins[14] | ~ins_pla_ands[17][14]) &
        (pla_ins[15] | ~ins_pla_ands[17][15]),
    (pla_ins[0] | ~ins_pla_ands[16][0]) &
        (pla_ins[1] | ~ins_pla_ands[16][1]) &
        (pla_ins[2] | ~ins_pla_ands[16][2]) &
        (pla_ins[3] | ~ins_pla_ands[16][3]) &
        (pla_ins[4] | ~ins_pla_ands[16][4]) &
        (pla_ins[5] | ~ins_pla_ands[16][5]) &
        (pla_ins[6] | ~ins_pla_ands[16][6]) &
        (pla_ins[7] | ~ins_pla_ands[16][7]) &
        (pla_ins[8] | ~ins_pla_ands[16][8]) &
        (pla_ins[9] | ~ins_pla_ands[16][9]) &
        (pla_ins[10] | ~ins_pla_ands[16][10]) &
        (pla_ins[11] | ~ins_pla_ands[16][11]) &
        (pla_ins[12] | ~ins_pla_ands[16][12]) &
        (pla_ins[13] | ~ins_pla_ands[16][13]) &
        (pla_ins[14] | ~ins_pla_ands[16][14]) &
        (pla_ins[15] | ~ins_pla_ands[16][15]),
    (pla_ins[0] | ~ins_pla_ands[15][0]) &
        (pla_ins[1] | ~ins_pla_ands[15][1]) &
        (pla_ins[2] | ~ins_pla_ands[15][2]) &
        (pla_ins[3] | ~ins_pla_ands[15][3]) &
        (pla_ins[4] | ~ins_pla_ands[15][4]) &
        (pla_ins[5] | ~ins_pla_ands[15][5]) &
        (pla_ins[6] | ~ins_pla_ands[15][6]) &
        (pla_ins[7] | ~ins_pla_ands[15][7]) &
        (pla_ins[8] | ~ins_pla_ands[15][8]) &
        (pla_ins[9] | ~ins_pla_ands[15][9]) &
        (pla_ins[10] | ~ins_pla_ands[15][10]) &
        (pla_ins[11] | ~ins_pla_ands[15][11]) &
        (pla_ins[12] | ~ins_pla_ands[15][12]) &
        (pla_ins[13] | ~ins_pla_ands[15][13]) &
        (pla_ins[14] | ~ins_pla_ands[15][14]) &
        (pla_ins[15] | ~ins_pla_ands[15][15]),
    (pla_ins[0] | ~ins_pla_ands[14][0]) &
        (pla_ins[1] | ~ins_pla_ands[14][1]) &
        (pla_ins[2] | ~ins_pla_ands[14][2]) &
        (pla_ins[3] | ~ins_pla_ands[14][3]) &
        (pla_ins[4] | ~ins_pla_ands[14][4]) &
        (pla_ins[5] | ~ins_pla_ands[14][5]) &
        (pla_ins[6] | ~ins_pla_ands[14][6]) &
        (pla_ins[7] | ~ins_pla_ands[14][7]) &
        (pla_ins[8] | ~ins_pla_ands[14][8]) &
        (pla_ins[9] | ~ins_pla_ands[14][9]) &
        (pla_ins[10] | ~ins_pla_ands[14][10]) &
        (pla_ins[11] | ~ins_pla_ands[14][11]) &
        (pla_ins[12] | ~ins_pla_ands[14][12]) &
        (pla_ins[13] | ~ins_pla_ands[14][13]) &
        (pla_ins[14] | ~ins_pla_ands[14][14]) &
        (pla_ins[15] | ~ins_pla_ands[14][15]),
    (pla_ins[0] | ~ins_pla_ands[13][0]) &
        (pla_ins[1] | ~ins_pla_ands[13][1]) &
        (pla_ins[2] | ~ins_pla_ands[13][2]) &
        (pla_ins[3] | ~ins_pla_ands[13][3]) &
        (pla_ins[4] | ~ins_pla_ands[13][4]) &
        (pla_ins[5] | ~ins_pla_ands[13][5]) &
        (pla_ins[6] | ~ins_pla_ands[13][6]) &
        (pla_ins[7] | ~ins_pla_ands[13][7]) &
        (pla_ins[8] | ~ins_pla_ands[13][8]) &
        (pla_ins[9] | ~ins_pla_ands[13][9]) &
        (pla_ins[10] | ~ins_pla_ands[13][10]) &
        (pla_ins[11] | ~ins_pla_ands[13][11]) &
        (pla_ins[12] | ~ins_pla_ands[13][12]) &
        (pla_ins[13] | ~ins_pla_ands[13][13]) &
        (pla_ins[14] | ~ins_pla_ands[13][14]) &
        (pla_ins[15] | ~ins_pla_ands[13][15]),
    (pla_ins[0] | ~ins_pla_ands[12][0]) &
        (pla_ins[1] | ~ins_pla_ands[12][1]) &
        (pla_ins[2] | ~ins_pla_ands[12][2]) &
        (pla_ins[3] | ~ins_pla_ands[12][3]) &
        (pla_ins[4] | ~ins_pla_ands[12][4]) &
        (pla_ins[5] | ~ins_pla_ands[12][5]) &
        (pla_ins[6] | ~ins_pla_ands[12][6]) &
        (pla_ins[7] | ~ins_pla_ands[12][7]) &
        (pla_ins[8] | ~ins_pla_ands[12][8]) &
        (pla_ins[9] | ~ins_pla_ands[12][9]) &
        (pla_ins[10] | ~ins_pla_ands[12][10]) &
        (pla_ins[11] | ~ins_pla_ands[12][11]) &
        (pla_ins[12] | ~ins_pla_ands[12][12]) &
        (pla_ins[13] | ~ins_pla_ands[12][13]) &
        (pla_ins[14] | ~ins_pla_ands[12][14]) &
        (pla_ins[15] | ~ins_pla_ands[12][15]),
    (pla_ins[0] | ~ins_pla_ands[11][0]) &
        (pla_ins[1] | ~ins_pla_ands[11][1]) &
        (pla_ins[2] | ~ins_pla_ands[11][2]) &
        (pla_ins[3] | ~ins_pla_ands[11][3]) &
        (pla_ins[4] | ~ins_pla_ands[11][4]) &
        (pla_ins[5] | ~ins_pla_ands[11][5]) &
        (pla_ins[6] | ~ins_pla_ands[11][6]) &
        (pla_ins[7] | ~ins_pla_ands[11][7]) &
        (pla_ins[8] | ~ins_pla_ands[11][8]) &
        (pla_ins[9] | ~ins_pla_ands[11][9]) &
        (pla_ins[10] | ~ins_pla_ands[11][10]) &
        (pla_ins[11] | ~ins_pla_ands[11][11]) &
        (pla_ins[12] | ~ins_pla_ands[11][12]) &
        (pla_ins[13] | ~ins_pla_ands[11][13]) &
        (pla_ins[14] | ~ins_pla_ands[11][14]) &
        (pla_ins[15] | ~ins_pla_ands[11][15]),
    (pla_ins[0] | ~ins_pla_ands[10][0]) &
        (pla_ins[1] | ~ins_pla_ands[10][1]) &
        (pla_ins[2] | ~ins_pla_ands[10][2]) &
        (pla_ins[3] | ~ins_pla_ands[10][3]) &
        (pla_ins[4] | ~ins_pla_ands[10][4]) &
        (pla_ins[5] | ~ins_pla_ands[10][5]) &
        (pla_ins[6] | ~ins_pla_ands[10][6]) &
        (pla_ins[7] | ~ins_pla_ands[10][7]) &
        (pla_ins[8] | ~ins_pla_ands[10][8]) &
        (pla_ins[9] | ~ins_pla_ands[10][9]) &
        (pla_ins[10] | ~ins_pla_ands[10][10]) &
        (pla_ins[11] | ~ins_pla_ands[10][11]) &
        (pla_ins[12] | ~ins_pla_ands[10][12]) &
        (pla_ins[13] | ~ins_pla_ands[10][13]) &
        (pla_ins[14] | ~ins_pla_ands[10][14]) &
        (pla_ins[15] | ~ins_pla_ands[10][15]),
    (pla_ins[0] | ~ins_pla_ands[9][0]) &
        (pla_ins[1] | ~ins_pla_ands[9][1]) &
        (pla_ins[2] | ~ins_pla_ands[9][2]) &
        (pla_ins[3] | ~ins_pla_ands[9][3]) &
        (pla_ins[4] | ~ins_pla_ands[9][4]) &
        (pla_ins[5] | ~ins_pla_ands[9][5]) &
        (pla_ins[6] | ~ins_pla_ands[9][6]) &
        (pla_ins[7] | ~ins_pla_ands[9][7]) &
        (pla_ins[8] | ~ins_pla_ands[9][8]) &
        (pla_ins[9] | ~ins_pla_ands[9][9]) &
        (pla_ins[10] | ~ins_pla_ands[9][10]) &
        (pla_ins[11] | ~ins_pla_ands[9][11]) &
        (pla_ins[12] | ~ins_pla_ands[9][12]) &
        (pla_ins[13] | ~ins_pla_ands[9][13]) &
        (pla_ins[14] | ~ins_pla_ands[9][14]) &
        (pla_ins[15] | ~ins_pla_ands[9][15]),
    (pla_ins[0] | ~ins_pla_ands[8][0]) &
        (pla_ins[1] | ~ins_pla_ands[8][1]) &
        (pla_ins[2] | ~ins_pla_ands[8][2]) &
        (pla_ins[3] | ~ins_pla_ands[8][3]) &
        (pla_ins[4] | ~ins_pla_ands[8][4]) &
        (pla_ins[5] | ~ins_pla_ands[8][5]) &
        (pla_ins[6] | ~ins_pla_ands[8][6]) &
        (pla_ins[7] | ~ins_pla_ands[8][7]) &
        (pla_ins[8] | ~ins_pla_ands[8][8]) &
        (pla_ins[9] | ~ins_pla_ands[8][9]) &
        (pla_ins[10] | ~ins_pla_ands[8][10]) &
        (pla_ins[11] | ~ins_pla_ands[8][11]) &
        (pla_ins[12] | ~ins_pla_ands[8][12]) &
        (pla_ins[13] | ~ins_pla_ands[8][13]) &
        (pla_ins[14] | ~ins_pla_ands[8][14]) &
        (pla_ins[15] | ~ins_pla_ands[8][15]),
    (pla_ins[0] | ~ins_pla_ands[7][0]) &
        (pla_ins[1] | ~ins_pla_ands[7][1]) &
        (pla_ins[2] | ~ins_pla_ands[7][2]) &
        (pla_ins[3] | ~ins_pla_ands[7][3]) &
        (pla_ins[4] | ~ins_pla_ands[7][4]) &
        (pla_ins[5] | ~ins_pla_ands[7][5]) &
        (pla_ins[6] | ~ins_pla_ands[7][6]) &
        (pla_ins[7] | ~ins_pla_ands[7][7]) &
        (pla_ins[8] | ~ins_pla_ands[7][8]) &
        (pla_ins[9] | ~ins_pla_ands[7][9]) &
        (pla_ins[10] | ~ins_pla_ands[7][10]) &
        (pla_ins[11] | ~ins_pla_ands[7][11]) &
        (pla_ins[12] | ~ins_pla_ands[7][12]) &
        (pla_ins[13] | ~ins_pla_ands[7][13]) &
        (pla_ins[14] | ~ins_pla_ands[7][14]) &
        (pla_ins[15] | ~ins_pla_ands[7][15]),
    (pla_ins[0] | ~ins_pla_ands[6][0]) &
        (pla_ins[1] | ~ins_pla_ands[6][1]) &
        (pla_ins[2] | ~ins_pla_ands[6][2]) &
        (pla_ins[3] | ~ins_pla_ands[6][3]) &
        (pla_ins[4] | ~ins_pla_ands[6][4]) &
        (pla_ins[5] | ~ins_pla_ands[6][5]) &
        (pla_ins[6] | ~ins_pla_ands[6][6]) &
        (pla_ins[7] | ~ins_pla_ands[6][7]) &
        (pla_ins[8] | ~ins_pla_ands[6][8]) &
        (pla_ins[9] | ~ins_pla_ands[6][9]) &
        (pla_ins[10] | ~ins_pla_ands[6][10]) &
        (pla_ins[11] | ~ins_pla_ands[6][11]) &
        (pla_ins[12] | ~ins_pla_ands[6][12]) &
        (pla_ins[13] | ~ins_pla_ands[6][13]) &
        (pla_ins[14] | ~ins_pla_ands[6][14]) &
        (pla_ins[15] | ~ins_pla_ands[6][15]),
    (pla_ins[0] | ~ins_pla_ands[5][0]) &
        (pla_ins[1] | ~ins_pla_ands[5][1]) &
        (pla_ins[2] | ~ins_pla_ands[5][2]) &
        (pla_ins[3] | ~ins_pla_ands[5][3]) &
        (pla_ins[4] | ~ins_pla_ands[5][4]) &
        (pla_ins[5] | ~ins_pla_ands[5][5]) &
        (pla_ins[6] | ~ins_pla_ands[5][6]) &
        (pla_ins[7] | ~ins_pla_ands[5][7]) &
        (pla_ins[8] | ~ins_pla_ands[5][8]) &
        (pla_ins[9] | ~ins_pla_ands[5][9]) &
        (pla_ins[10] | ~ins_pla_ands[5][10]) &
        (pla_ins[11] | ~ins_pla_ands[5][11]) &
        (pla_ins[12] | ~ins_pla_ands[5][12]) &
        (pla_ins[13] | ~ins_pla_ands[5][13]) &
        (pla_ins[14] | ~ins_pla_ands[5][14]) &
        (pla_ins[15] | ~ins_pla_ands[5][15]),
    (pla_ins[0] | ~ins_pla_ands[4][0]) &
        (pla_ins[1] | ~ins_pla_ands[4][1]) &
        (pla_ins[2] | ~ins_pla_ands[4][2]) &
        (pla_ins[3] | ~ins_pla_ands[4][3]) &
        (pla_ins[4] | ~ins_pla_ands[4][4]) &
        (pla_ins[5] | ~ins_pla_ands[4][5]) &
        (pla_ins[6] | ~ins_pla_ands[4][6]) &
        (pla_ins[7] | ~ins_pla_ands[4][7]) &
        (pla_ins[8] | ~ins_pla_ands[4][8]) &
        (pla_ins[9] | ~ins_pla_ands[4][9]) &
        (pla_ins[10] | ~ins_pla_ands[4][10]) &
        (pla_ins[11] | ~ins_pla_ands[4][11]) &
        (pla_ins[12] | ~ins_pla_ands[4][12]) &
        (pla_ins[13] | ~ins_pla_ands[4][13]) &
        (pla_ins[14] | ~ins_pla_ands[4][14]) &
        (pla_ins[15] | ~ins_pla_ands[4][15]),
    (pla_ins[0] | ~ins_pla_ands[3][0]) &
        (pla_ins[1] | ~ins_pla_ands[3][1]) &
        (pla_ins[2] | ~ins_pla_ands[3][2]) &
        (pla_ins[3] | ~ins_pla_ands[3][3]) &
        (pla_ins[4] | ~ins_pla_ands[3][4]) &
        (pla_ins[5] | ~ins_pla_ands[3][5]) &
        (pla_ins[6] | ~ins_pla_ands[3][6]) &
        (pla_ins[7] | ~ins_pla_ands[3][7]) &
        (pla_ins[8] | ~ins_pla_ands[3][8]) &
        (pla_ins[9] | ~ins_pla_ands[3][9]) &
        (pla_ins[10] | ~ins_pla_ands[3][10]) &
        (pla_ins[11] | ~ins_pla_ands[3][11]) &
        (pla_ins[12] | ~ins_pla_ands[3][12]) &
        (pla_ins[13] | ~ins_pla_ands[3][13]) &
        (pla_ins[14] | ~ins_pla_ands[3][14]) &
        (pla_ins[15] | ~ins_pla_ands[3][15]),
    (pla_ins[0] | ~ins_pla_ands[2][0]) &
        (pla_ins[1] | ~ins_pla_ands[2][1]) &
        (pla_ins[2] | ~ins_pla_ands[2][2]) &
        (pla_ins[3] | ~ins_pla_ands[2][3]) &
        (pla_ins[4] | ~ins_pla_ands[2][4]) &
        (pla_ins[5] | ~ins_pla_ands[2][5]) &
        (pla_ins[6] | ~ins_pla_ands[2][6]) &
        (pla_ins[7] | ~ins_pla_ands[2][7]) &
        (pla_ins[8] | ~ins_pla_ands[2][8]) &
        (pla_ins[9] | ~ins_pla_ands[2][9]) &
        (pla_ins[10] | ~ins_pla_ands[2][10]) &
        (pla_ins[11] | ~ins_pla_ands[2][11]) &
        (pla_ins[12] | ~ins_pla_ands[2][12]) &
        (pla_ins[13] | ~ins_pla_ands[2][13]) &
        (pla_ins[14] | ~ins_pla_ands[2][14]) &
        (pla_ins[15] | ~ins_pla_ands[2][15]),
    (pla_ins[0] | ~ins_pla_ands[1][0]) &
        (pla_ins[1] | ~ins_pla_ands[1][1]) &
        (pla_ins[2] | ~ins_pla_ands[1][2]) &
        (pla_ins[3] | ~ins_pla_ands[1][3]) &
        (pla_ins[4] | ~ins_pla_ands[1][4]) &
        (pla_ins[5] | ~ins_pla_ands[1][5]) &
        (pla_ins[6] | ~ins_pla_ands[1][6]) &
        (pla_ins[7] | ~ins_pla_ands[1][7]) &
        (pla_ins[8] | ~ins_pla_ands[1][8]) &
        (pla_ins[9] | ~ins_pla_ands[1][9]) &
        (pla_ins[10] | ~ins_pla_ands[1][10]) &
        (pla_ins[11] | ~ins_pla_ands[1][11]) &
        (pla_ins[12] | ~ins_pla_ands[1][12]) &
        (pla_ins[13] | ~ins_pla_ands[1][13]) &
        (pla_ins[14] | ~ins_pla_ands[1][14]) &
        (pla_ins[15] | ~ins_pla_ands[1][15]),
    (pla_ins[0] | ~ins_pla_ands[0][0]) &
        (pla_ins[1] | ~ins_pla_ands[0][1]) &
        (pla_ins[2] | ~ins_pla_ands[0][2]) &
        (pla_ins[3] | ~ins_pla_ands[0][3]) &
        (pla_ins[4] | ~ins_pla_ands[0][4]) &
        (pla_ins[5] | ~ins_pla_ands[0][5]) &
        (pla_ins[6] | ~ins_pla_ands[0][6]) &
        (pla_ins[7] | ~ins_pla_ands[0][7]) &
        (pla_ins[8] | ~ins_pla_ands[0][8]) &
        (pla_ins[9] | ~ins_pla_ands[0][9]) &
        (pla_ins[10] | ~ins_pla_ands[0][10]) &
        (pla_ins[11] | ~ins_pla_ands[0][11]) &
        (pla_ins[12] | ~ins_pla_ands[0][12]) &
        (pla_ins[13] | ~ins_pla_ands[0][13]) &
        (pla_ins[14] | ~ins_pla_ands[0][14]) &
        (pla_ins[15] | ~ins_pla_ands[0][15])
};

wire [15:0] ins_or_outs = {
    (ins_pla_ors[15][0] & ins_and_outs[0]) |
        (ins_pla_ors[15][1] & ins_and_outs[1]) |
        (ins_pla_ors[15][2] & ins_and_outs[2]) |
        (ins_pla_ors[15][3] & ins_and_outs[3]) |
        (ins_pla_ors[15][4] & ins_and_outs[4]) |
        (ins_pla_ors[15][5] & ins_and_outs[5]) |
        (ins_pla_ors[15][6] & ins_and_outs[6]) |
        (ins_pla_ors[15][7] & ins_and_outs[7]) |
        (ins_pla_ors[15][8] & ins_and_outs[8]) |
        (ins_pla_ors[15][9] & ins_and_outs[9]) |
        (ins_pla_ors[15][10] & ins_and_outs[10]) |
        (ins_pla_ors[15][11] & ins_and_outs[11]) |
        (ins_pla_ors[15][12] & ins_and_outs[12]) |
        (ins_pla_ors[15][13] & ins_and_outs[13]) |
        (ins_pla_ors[15][14] & ins_and_outs[14]) |
        (ins_pla_ors[15][15] & ins_and_outs[15]) |
        (ins_pla_ors[15][16] & ins_and_outs[16]) |
        (ins_pla_ors[15][17] & ins_and_outs[17]) |
        (ins_pla_ors[15][18] & ins_and_outs[18]) |
        (ins_pla_ors[15][19] & ins_and_outs[19]) |
        (ins_pla_ors[15][20] & ins_and_outs[20]) |
        (ins_pla_ors[15][21] & ins_and_outs[21]) |
        (ins_pla_ors[15][22] & ins_and_outs[22]) |
        (ins_pla_ors[15][23] & ins_and_outs[23]) |
        (ins_pla_ors[15][24] & ins_and_outs[24]) |
        (ins_pla_ors[15][25] & ins_and_outs[25]) |
        (ins_pla_ors[15][26] & ins_and_outs[26]) |
        (ins_pla_ors[15][27] & ins_and_outs[27]) |
        (ins_pla_ors[15][28] & ins_and_outs[28]) |
        (ins_pla_ors[15][29] & ins_and_outs[29]),
    (ins_pla_ors[14][0] & ins_and_outs[0]) |
        (ins_pla_ors[14][1] & ins_and_outs[1]) |
        (ins_pla_ors[14][2] & ins_and_outs[2]) |
        (ins_pla_ors[14][3] & ins_and_outs[3]) |
        (ins_pla_ors[14][4] & ins_and_outs[4]) |
        (ins_pla_ors[14][5] & ins_and_outs[5]) |
        (ins_pla_ors[14][6] & ins_and_outs[6]) |
        (ins_pla_ors[14][7] & ins_and_outs[7]) |
        (ins_pla_ors[14][8] & ins_and_outs[8]) |
        (ins_pla_ors[14][9] & ins_and_outs[9]) |
        (ins_pla_ors[14][10] & ins_and_outs[10]) |
        (ins_pla_ors[14][11] & ins_and_outs[11]) |
        (ins_pla_ors[14][12] & ins_and_outs[12]) |
        (ins_pla_ors[14][13] & ins_and_outs[13]) |
        (ins_pla_ors[14][14] & ins_and_outs[14]) |
        (ins_pla_ors[14][15] & ins_and_outs[15]) |
        (ins_pla_ors[14][16] & ins_and_outs[16]) |
        (ins_pla_ors[14][17] & ins_and_outs[17]) |
        (ins_pla_ors[14][18] & ins_and_outs[18]) |
        (ins_pla_ors[14][19] & ins_and_outs[19]) |
        (ins_pla_ors[14][20] & ins_and_outs[20]) |
        (ins_pla_ors[14][21] & ins_and_outs[21]) |
        (ins_pla_ors[14][22] & ins_and_outs[22]) |
        (ins_pla_ors[14][23] & ins_and_outs[23]) |
        (ins_pla_ors[14][24] & ins_and_outs[24]) |
        (ins_pla_ors[14][25] & ins_and_outs[25]) |
        (ins_pla_ors[14][26] & ins_and_outs[26]) |
        (ins_pla_ors[14][27] & ins_and_outs[27]) |
        (ins_pla_ors[14][28] & ins_and_outs[28]) |
        (ins_pla_ors[14][29] & ins_and_outs[29]),
    (ins_pla_ors[13][0] & ins_and_outs[0]) |
        (ins_pla_ors[13][1] & ins_and_outs[1]) |
        (ins_pla_ors[13][2] & ins_and_outs[2]) |
        (ins_pla_ors[13][3] & ins_and_outs[3]) |
        (ins_pla_ors[13][4] & ins_and_outs[4]) |
        (ins_pla_ors[13][5] & ins_and_outs[5]) |
        (ins_pla_ors[13][6] & ins_and_outs[6]) |
        (ins_pla_ors[13][7] & ins_and_outs[7]) |
        (ins_pla_ors[13][8] & ins_and_outs[8]) |
        (ins_pla_ors[13][9] & ins_and_outs[9]) |
        (ins_pla_ors[13][10] & ins_and_outs[10]) |
        (ins_pla_ors[13][11] & ins_and_outs[11]) |
        (ins_pla_ors[13][12] & ins_and_outs[12]) |
        (ins_pla_ors[13][13] & ins_and_outs[13]) |
        (ins_pla_ors[13][14] & ins_and_outs[14]) |
        (ins_pla_ors[13][15] & ins_and_outs[15]) |
        (ins_pla_ors[13][16] & ins_and_outs[16]) |
        (ins_pla_ors[13][17] & ins_and_outs[17]) |
        (ins_pla_ors[13][18] & ins_and_outs[18]) |
        (ins_pla_ors[13][19] & ins_and_outs[19]) |
        (ins_pla_ors[13][20] & ins_and_outs[20]) |
        (ins_pla_ors[13][21] & ins_and_outs[21]) |
        (ins_pla_ors[13][22] & ins_and_outs[22]) |
        (ins_pla_ors[13][23] & ins_and_outs[23]) |
        (ins_pla_ors[13][24] & ins_and_outs[24]) |
        (ins_pla_ors[13][25] & ins_and_outs[25]) |
        (ins_pla_ors[13][26] & ins_and_outs[26]) |
        (ins_pla_ors[13][27] & ins_and_outs[27]) |
        (ins_pla_ors[13][28] & ins_and_outs[28]) |
        (ins_pla_ors[13][29] & ins_and_outs[29]),
    (ins_pla_ors[12][0] & ins_and_outs[0]) |
        (ins_pla_ors[12][1] & ins_and_outs[1]) |
        (ins_pla_ors[12][2] & ins_and_outs[2]) |
        (ins_pla_ors[12][3] & ins_and_outs[3]) |
        (ins_pla_ors[12][4] & ins_and_outs[4]) |
        (ins_pla_ors[12][5] & ins_and_outs[5]) |
        (ins_pla_ors[12][6] & ins_and_outs[6]) |
        (ins_pla_ors[12][7] & ins_and_outs[7]) |
        (ins_pla_ors[12][8] & ins_and_outs[8]) |
        (ins_pla_ors[12][9] & ins_and_outs[9]) |
        (ins_pla_ors[12][10] & ins_and_outs[10]) |
        (ins_pla_ors[12][11] & ins_and_outs[11]) |
        (ins_pla_ors[12][12] & ins_and_outs[12]) |
        (ins_pla_ors[12][13] & ins_and_outs[13]) |
        (ins_pla_ors[12][14] & ins_and_outs[14]) |
        (ins_pla_ors[12][15] & ins_and_outs[15]) |
        (ins_pla_ors[12][16] & ins_and_outs[16]) |
        (ins_pla_ors[12][17] & ins_and_outs[17]) |
        (ins_pla_ors[12][18] & ins_and_outs[18]) |
        (ins_pla_ors[12][19] & ins_and_outs[19]) |
        (ins_pla_ors[12][20] & ins_and_outs[20]) |
        (ins_pla_ors[12][21] & ins_and_outs[21]) |
        (ins_pla_ors[12][22] & ins_and_outs[22]) |
        (ins_pla_ors[12][23] & ins_and_outs[23]) |
        (ins_pla_ors[12][24] & ins_and_outs[24]) |
        (ins_pla_ors[12][25] & ins_and_outs[25]) |
        (ins_pla_ors[12][26] & ins_and_outs[26]) |
        (ins_pla_ors[12][27] & ins_and_outs[27]) |
        (ins_pla_ors[12][28] & ins_and_outs[28]) |
        (ins_pla_ors[12][29] & ins_and_outs[29]),
    (ins_pla_ors[11][0] & ins_and_outs[0]) |
        (ins_pla_ors[11][1] & ins_and_outs[1]) |
        (ins_pla_ors[11][2] & ins_and_outs[2]) |
        (ins_pla_ors[11][3] & ins_and_outs[3]) |
        (ins_pla_ors[11][4] & ins_and_outs[4]) |
        (ins_pla_ors[11][5] & ins_and_outs[5]) |
        (ins_pla_ors[11][6] & ins_and_outs[6]) |
        (ins_pla_ors[11][7] & ins_and_outs[7]) |
        (ins_pla_ors[11][8] & ins_and_outs[8]) |
        (ins_pla_ors[11][9] & ins_and_outs[9]) |
        (ins_pla_ors[11][10] & ins_and_outs[10]) |
        (ins_pla_ors[11][11] & ins_and_outs[11]) |
        (ins_pla_ors[11][12] & ins_and_outs[12]) |
        (ins_pla_ors[11][13] & ins_and_outs[13]) |
        (ins_pla_ors[11][14] & ins_and_outs[14]) |
        (ins_pla_ors[11][15] & ins_and_outs[15]) |
        (ins_pla_ors[11][16] & ins_and_outs[16]) |
        (ins_pla_ors[11][17] & ins_and_outs[17]) |
        (ins_pla_ors[11][18] & ins_and_outs[18]) |
        (ins_pla_ors[11][19] & ins_and_outs[19]) |
        (ins_pla_ors[11][20] & ins_and_outs[20]) |
        (ins_pla_ors[11][21] & ins_and_outs[21]) |
        (ins_pla_ors[11][22] & ins_and_outs[22]) |
        (ins_pla_ors[11][23] & ins_and_outs[23]) |
        (ins_pla_ors[11][24] & ins_and_outs[24]) |
        (ins_pla_ors[11][25] & ins_and_outs[25]) |
        (ins_pla_ors[11][26] & ins_and_outs[26]) |
        (ins_pla_ors[11][27] & ins_and_outs[27]) |
        (ins_pla_ors[11][28] & ins_and_outs[28]) |
        (ins_pla_ors[11][29] & ins_and_outs[29]),
    (ins_pla_ors[10][0] & ins_and_outs[0]) |
        (ins_pla_ors[10][1] & ins_and_outs[1]) |
        (ins_pla_ors[10][2] & ins_and_outs[2]) |
        (ins_pla_ors[10][3] & ins_and_outs[3]) |
        (ins_pla_ors[10][4] & ins_and_outs[4]) |
        (ins_pla_ors[10][5] & ins_and_outs[5]) |
        (ins_pla_ors[10][6] & ins_and_outs[6]) |
        (ins_pla_ors[10][7] & ins_and_outs[7]) |
        (ins_pla_ors[10][8] & ins_and_outs[8]) |
        (ins_pla_ors[10][9] & ins_and_outs[9]) |
        (ins_pla_ors[10][10] & ins_and_outs[10]) |
        (ins_pla_ors[10][11] & ins_and_outs[11]) |
        (ins_pla_ors[10][12] & ins_and_outs[12]) |
        (ins_pla_ors[10][13] & ins_and_outs[13]) |
        (ins_pla_ors[10][14] & ins_and_outs[14]) |
        (ins_pla_ors[10][15] & ins_and_outs[15]) |
        (ins_pla_ors[10][16] & ins_and_outs[16]) |
        (ins_pla_ors[10][17] & ins_and_outs[17]) |
        (ins_pla_ors[10][18] & ins_and_outs[18]) |
        (ins_pla_ors[10][19] & ins_and_outs[19]) |
        (ins_pla_ors[10][20] & ins_and_outs[20]) |
        (ins_pla_ors[10][21] & ins_and_outs[21]) |
        (ins_pla_ors[10][22] & ins_and_outs[22]) |
        (ins_pla_ors[10][23] & ins_and_outs[23]) |
        (ins_pla_ors[10][24] & ins_and_outs[24]) |
        (ins_pla_ors[10][25] & ins_and_outs[25]) |
        (ins_pla_ors[10][26] & ins_and_outs[26]) |
        (ins_pla_ors[10][27] & ins_and_outs[27]) |
        (ins_pla_ors[10][28] & ins_and_outs[28]) |
        (ins_pla_ors[10][29] & ins_and_outs[29]),
    (ins_pla_ors[9][0] & ins_and_outs[0]) |
        (ins_pla_ors[9][1] & ins_and_outs[1]) |
        (ins_pla_ors[9][2] & ins_and_outs[2]) |
        (ins_pla_ors[9][3] & ins_and_outs[3]) |
        (ins_pla_ors[9][4] & ins_and_outs[4]) |
        (ins_pla_ors[9][5] & ins_and_outs[5]) |
        (ins_pla_ors[9][6] & ins_and_outs[6]) |
        (ins_pla_ors[9][7] & ins_and_outs[7]) |
        (ins_pla_ors[9][8] & ins_and_outs[8]) |
        (ins_pla_ors[9][9] & ins_and_outs[9]) |
        (ins_pla_ors[9][10] & ins_and_outs[10]) |
        (ins_pla_ors[9][11] & ins_and_outs[11]) |
        (ins_pla_ors[9][12] & ins_and_outs[12]) |
        (ins_pla_ors[9][13] & ins_and_outs[13]) |
        (ins_pla_ors[9][14] & ins_and_outs[14]) |
        (ins_pla_ors[9][15] & ins_and_outs[15]) |
        (ins_pla_ors[9][16] & ins_and_outs[16]) |
        (ins_pla_ors[9][17] & ins_and_outs[17]) |
        (ins_pla_ors[9][18] & ins_and_outs[18]) |
        (ins_pla_ors[9][19] & ins_and_outs[19]) |
        (ins_pla_ors[9][20] & ins_and_outs[20]) |
        (ins_pla_ors[9][21] & ins_and_outs[21]) |
        (ins_pla_ors[9][22] & ins_and_outs[22]) |
        (ins_pla_ors[9][23] & ins_and_outs[23]) |
        (ins_pla_ors[9][24] & ins_and_outs[24]) |
        (ins_pla_ors[9][25] & ins_and_outs[25]) |
        (ins_pla_ors[9][26] & ins_and_outs[26]) |
        (ins_pla_ors[9][27] & ins_and_outs[27]) |
        (ins_pla_ors[9][28] & ins_and_outs[28]) |
        (ins_pla_ors[9][29] & ins_and_outs[29]),
    (ins_pla_ors[8][0] & ins_and_outs[0]) |
        (ins_pla_ors[8][1] & ins_and_outs[1]) |
        (ins_pla_ors[8][2] & ins_and_outs[2]) |
        (ins_pla_ors[8][3] & ins_and_outs[3]) |
        (ins_pla_ors[8][4] & ins_and_outs[4]) |
        (ins_pla_ors[8][5] & ins_and_outs[5]) |
        (ins_pla_ors[8][6] & ins_and_outs[6]) |
        (ins_pla_ors[8][7] & ins_and_outs[7]) |
        (ins_pla_ors[8][8] & ins_and_outs[8]) |
        (ins_pla_ors[8][9] & ins_and_outs[9]) |
        (ins_pla_ors[8][10] & ins_and_outs[10]) |
        (ins_pla_ors[8][11] & ins_and_outs[11]) |
        (ins_pla_ors[8][12] & ins_and_outs[12]) |
        (ins_pla_ors[8][13] & ins_and_outs[13]) |
        (ins_pla_ors[8][14] & ins_and_outs[14]) |
        (ins_pla_ors[8][15] & ins_and_outs[15]) |
        (ins_pla_ors[8][16] & ins_and_outs[16]) |
        (ins_pla_ors[8][17] & ins_and_outs[17]) |
        (ins_pla_ors[8][18] & ins_and_outs[18]) |
        (ins_pla_ors[8][19] & ins_and_outs[19]) |
        (ins_pla_ors[8][20] & ins_and_outs[20]) |
        (ins_pla_ors[8][21] & ins_and_outs[21]) |
        (ins_pla_ors[8][22] & ins_and_outs[22]) |
        (ins_pla_ors[8][23] & ins_and_outs[23]) |
        (ins_pla_ors[8][24] & ins_and_outs[24]) |
        (ins_pla_ors[8][25] & ins_and_outs[25]) |
        (ins_pla_ors[8][26] & ins_and_outs[26]) |
        (ins_pla_ors[8][27] & ins_and_outs[27]) |
        (ins_pla_ors[8][28] & ins_and_outs[28]) |
        (ins_pla_ors[8][29] & ins_and_outs[29]),
    (ins_pla_ors[7][0] & ins_and_outs[0]) |
        (ins_pla_ors[7][1] & ins_and_outs[1]) |
        (ins_pla_ors[7][2] & ins_and_outs[2]) |
        (ins_pla_ors[7][3] & ins_and_outs[3]) |
        (ins_pla_ors[7][4] & ins_and_outs[4]) |
        (ins_pla_ors[7][5] & ins_and_outs[5]) |
        (ins_pla_ors[7][6] & ins_and_outs[6]) |
        (ins_pla_ors[7][7] & ins_and_outs[7]) |
        (ins_pla_ors[7][8] & ins_and_outs[8]) |
        (ins_pla_ors[7][9] & ins_and_outs[9]) |
        (ins_pla_ors[7][10] & ins_and_outs[10]) |
        (ins_pla_ors[7][11] & ins_and_outs[11]) |
        (ins_pla_ors[7][12] & ins_and_outs[12]) |
        (ins_pla_ors[7][13] & ins_and_outs[13]) |
        (ins_pla_ors[7][14] & ins_and_outs[14]) |
        (ins_pla_ors[7][15] & ins_and_outs[15]) |
        (ins_pla_ors[7][16] & ins_and_outs[16]) |
        (ins_pla_ors[7][17] & ins_and_outs[17]) |
        (ins_pla_ors[7][18] & ins_and_outs[18]) |
        (ins_pla_ors[7][19] & ins_and_outs[19]) |
        (ins_pla_ors[7][20] & ins_and_outs[20]) |
        (ins_pla_ors[7][21] & ins_and_outs[21]) |
        (ins_pla_ors[7][22] & ins_and_outs[22]) |
        (ins_pla_ors[7][23] & ins_and_outs[23]) |
        (ins_pla_ors[7][24] & ins_and_outs[24]) |
        (ins_pla_ors[7][25] & ins_and_outs[25]) |
        (ins_pla_ors[7][26] & ins_and_outs[26]) |
        (ins_pla_ors[7][27] & ins_and_outs[27]) |
        (ins_pla_ors[7][28] & ins_and_outs[28]) |
        (ins_pla_ors[7][29] & ins_and_outs[29]),
    (ins_pla_ors[6][0] & ins_and_outs[0]) |
        (ins_pla_ors[6][1] & ins_and_outs[1]) |
        (ins_pla_ors[6][2] & ins_and_outs[2]) |
        (ins_pla_ors[6][3] & ins_and_outs[3]) |
        (ins_pla_ors[6][4] & ins_and_outs[4]) |
        (ins_pla_ors[6][5] & ins_and_outs[5]) |
        (ins_pla_ors[6][6] & ins_and_outs[6]) |
        (ins_pla_ors[6][7] & ins_and_outs[7]) |
        (ins_pla_ors[6][8] & ins_and_outs[8]) |
        (ins_pla_ors[6][9] & ins_and_outs[9]) |
        (ins_pla_ors[6][10] & ins_and_outs[10]) |
        (ins_pla_ors[6][11] & ins_and_outs[11]) |
        (ins_pla_ors[6][12] & ins_and_outs[12]) |
        (ins_pla_ors[6][13] & ins_and_outs[13]) |
        (ins_pla_ors[6][14] & ins_and_outs[14]) |
        (ins_pla_ors[6][15] & ins_and_outs[15]) |
        (ins_pla_ors[6][16] & ins_and_outs[16]) |
        (ins_pla_ors[6][17] & ins_and_outs[17]) |
        (ins_pla_ors[6][18] & ins_and_outs[18]) |
        (ins_pla_ors[6][19] & ins_and_outs[19]) |
        (ins_pla_ors[6][20] & ins_and_outs[20]) |
        (ins_pla_ors[6][21] & ins_and_outs[21]) |
        (ins_pla_ors[6][22] & ins_and_outs[22]) |
        (ins_pla_ors[6][23] & ins_and_outs[23]) |
        (ins_pla_ors[6][24] & ins_and_outs[24]) |
        (ins_pla_ors[6][25] & ins_and_outs[25]) |
        (ins_pla_ors[6][26] & ins_and_outs[26]) |
        (ins_pla_ors[6][27] & ins_and_outs[27]) |
        (ins_pla_ors[6][28] & ins_and_outs[28]) |
        (ins_pla_ors[6][29] & ins_and_outs[29]),
    (ins_pla_ors[5][0] & ins_and_outs[0]) |
        (ins_pla_ors[5][1] & ins_and_outs[1]) |
        (ins_pla_ors[5][2] & ins_and_outs[2]) |
        (ins_pla_ors[5][3] & ins_and_outs[3]) |
        (ins_pla_ors[5][4] & ins_and_outs[4]) |
        (ins_pla_ors[5][5] & ins_and_outs[5]) |
        (ins_pla_ors[5][6] & ins_and_outs[6]) |
        (ins_pla_ors[5][7] & ins_and_outs[7]) |
        (ins_pla_ors[5][8] & ins_and_outs[8]) |
        (ins_pla_ors[5][9] & ins_and_outs[9]) |
        (ins_pla_ors[5][10] & ins_and_outs[10]) |
        (ins_pla_ors[5][11] & ins_and_outs[11]) |
        (ins_pla_ors[5][12] & ins_and_outs[12]) |
        (ins_pla_ors[5][13] & ins_and_outs[13]) |
        (ins_pla_ors[5][14] & ins_and_outs[14]) |
        (ins_pla_ors[5][15] & ins_and_outs[15]) |
        (ins_pla_ors[5][16] & ins_and_outs[16]) |
        (ins_pla_ors[5][17] & ins_and_outs[17]) |
        (ins_pla_ors[5][18] & ins_and_outs[18]) |
        (ins_pla_ors[5][19] & ins_and_outs[19]) |
        (ins_pla_ors[5][20] & ins_and_outs[20]) |
        (ins_pla_ors[5][21] & ins_and_outs[21]) |
        (ins_pla_ors[5][22] & ins_and_outs[22]) |
        (ins_pla_ors[5][23] & ins_and_outs[23]) |
        (ins_pla_ors[5][24] & ins_and_outs[24]) |
        (ins_pla_ors[5][25] & ins_and_outs[25]) |
        (ins_pla_ors[5][26] & ins_and_outs[26]) |
        (ins_pla_ors[5][27] & ins_and_outs[27]) |
        (ins_pla_ors[5][28] & ins_and_outs[28]) |
        (ins_pla_ors[5][29] & ins_and_outs[29]),
    (ins_pla_ors[4][0] & ins_and_outs[0]) |
        (ins_pla_ors[4][1] & ins_and_outs[1]) |
        (ins_pla_ors[4][2] & ins_and_outs[2]) |
        (ins_pla_ors[4][3] & ins_and_outs[3]) |
        (ins_pla_ors[4][4] & ins_and_outs[4]) |
        (ins_pla_ors[4][5] & ins_and_outs[5]) |
        (ins_pla_ors[4][6] & ins_and_outs[6]) |
        (ins_pla_ors[4][7] & ins_and_outs[7]) |
        (ins_pla_ors[4][8] & ins_and_outs[8]) |
        (ins_pla_ors[4][9] & ins_and_outs[9]) |
        (ins_pla_ors[4][10] & ins_and_outs[10]) |
        (ins_pla_ors[4][11] & ins_and_outs[11]) |
        (ins_pla_ors[4][12] & ins_and_outs[12]) |
        (ins_pla_ors[4][13] & ins_and_outs[13]) |
        (ins_pla_ors[4][14] & ins_and_outs[14]) |
        (ins_pla_ors[4][15] & ins_and_outs[15]) |
        (ins_pla_ors[4][16] & ins_and_outs[16]) |
        (ins_pla_ors[4][17] & ins_and_outs[17]) |
        (ins_pla_ors[4][18] & ins_and_outs[18]) |
        (ins_pla_ors[4][19] & ins_and_outs[19]) |
        (ins_pla_ors[4][20] & ins_and_outs[20]) |
        (ins_pla_ors[4][21] & ins_and_outs[21]) |
        (ins_pla_ors[4][22] & ins_and_outs[22]) |
        (ins_pla_ors[4][23] & ins_and_outs[23]) |
        (ins_pla_ors[4][24] & ins_and_outs[24]) |
        (ins_pla_ors[4][25] & ins_and_outs[25]) |
        (ins_pla_ors[4][26] & ins_and_outs[26]) |
        (ins_pla_ors[4][27] & ins_and_outs[27]) |
        (ins_pla_ors[4][28] & ins_and_outs[28]) |
        (ins_pla_ors[4][29] & ins_and_outs[29]),
    (ins_pla_ors[3][0] & ins_and_outs[0]) |
        (ins_pla_ors[3][1] & ins_and_outs[1]) |
        (ins_pla_ors[3][2] & ins_and_outs[2]) |
        (ins_pla_ors[3][3] & ins_and_outs[3]) |
        (ins_pla_ors[3][4] & ins_and_outs[4]) |
        (ins_pla_ors[3][5] & ins_and_outs[5]) |
        (ins_pla_ors[3][6] & ins_and_outs[6]) |
        (ins_pla_ors[3][7] & ins_and_outs[7]) |
        (ins_pla_ors[3][8] & ins_and_outs[8]) |
        (ins_pla_ors[3][9] & ins_and_outs[9]) |
        (ins_pla_ors[3][10] & ins_and_outs[10]) |
        (ins_pla_ors[3][11] & ins_and_outs[11]) |
        (ins_pla_ors[3][12] & ins_and_outs[12]) |
        (ins_pla_ors[3][13] & ins_and_outs[13]) |
        (ins_pla_ors[3][14] & ins_and_outs[14]) |
        (ins_pla_ors[3][15] & ins_and_outs[15]) |
        (ins_pla_ors[3][16] & ins_and_outs[16]) |
        (ins_pla_ors[3][17] & ins_and_outs[17]) |
        (ins_pla_ors[3][18] & ins_and_outs[18]) |
        (ins_pla_ors[3][19] & ins_and_outs[19]) |
        (ins_pla_ors[3][20] & ins_and_outs[20]) |
        (ins_pla_ors[3][21] & ins_and_outs[21]) |
        (ins_pla_ors[3][22] & ins_and_outs[22]) |
        (ins_pla_ors[3][23] & ins_and_outs[23]) |
        (ins_pla_ors[3][24] & ins_and_outs[24]) |
        (ins_pla_ors[3][25] & ins_and_outs[25]) |
        (ins_pla_ors[3][26] & ins_and_outs[26]) |
        (ins_pla_ors[3][27] & ins_and_outs[27]) |
        (ins_pla_ors[3][28] & ins_and_outs[28]) |
        (ins_pla_ors[3][29] & ins_and_outs[29]),
    (ins_pla_ors[2][0] & ins_and_outs[0]) |
        (ins_pla_ors[2][1] & ins_and_outs[1]) |
        (ins_pla_ors[2][2] & ins_and_outs[2]) |
        (ins_pla_ors[2][3] & ins_and_outs[3]) |
        (ins_pla_ors[2][4] & ins_and_outs[4]) |
        (ins_pla_ors[2][5] & ins_and_outs[5]) |
        (ins_pla_ors[2][6] & ins_and_outs[6]) |
        (ins_pla_ors[2][7] & ins_and_outs[7]) |
        (ins_pla_ors[2][8] & ins_and_outs[8]) |
        (ins_pla_ors[2][9] & ins_and_outs[9]) |
        (ins_pla_ors[2][10] & ins_and_outs[10]) |
        (ins_pla_ors[2][11] & ins_and_outs[11]) |
        (ins_pla_ors[2][12] & ins_and_outs[12]) |
        (ins_pla_ors[2][13] & ins_and_outs[13]) |
        (ins_pla_ors[2][14] & ins_and_outs[14]) |
        (ins_pla_ors[2][15] & ins_and_outs[15]) |
        (ins_pla_ors[2][16] & ins_and_outs[16]) |
        (ins_pla_ors[2][17] & ins_and_outs[17]) |
        (ins_pla_ors[2][18] & ins_and_outs[18]) |
        (ins_pla_ors[2][19] & ins_and_outs[19]) |
        (ins_pla_ors[2][20] & ins_and_outs[20]) |
        (ins_pla_ors[2][21] & ins_and_outs[21]) |
        (ins_pla_ors[2][22] & ins_and_outs[22]) |
        (ins_pla_ors[2][23] & ins_and_outs[23]) |
        (ins_pla_ors[2][24] & ins_and_outs[24]) |
        (ins_pla_ors[2][25] & ins_and_outs[25]) |
        (ins_pla_ors[2][26] & ins_and_outs[26]) |
        (ins_pla_ors[2][27] & ins_and_outs[27]) |
        (ins_pla_ors[2][28] & ins_and_outs[28]) |
        (ins_pla_ors[2][29] & ins_and_outs[29]),
    (ins_pla_ors[1][0] & ins_and_outs[0]) |
        (ins_pla_ors[1][1] & ins_and_outs[1]) |
        (ins_pla_ors[1][2] & ins_and_outs[2]) |
        (ins_pla_ors[1][3] & ins_and_outs[3]) |
        (ins_pla_ors[1][4] & ins_and_outs[4]) |
        (ins_pla_ors[1][5] & ins_and_outs[5]) |
        (ins_pla_ors[1][6] & ins_and_outs[6]) |
        (ins_pla_ors[1][7] & ins_and_outs[7]) |
        (ins_pla_ors[1][8] & ins_and_outs[8]) |
        (ins_pla_ors[1][9] & ins_and_outs[9]) |
        (ins_pla_ors[1][10] & ins_and_outs[10]) |
        (ins_pla_ors[1][11] & ins_and_outs[11]) |
        (ins_pla_ors[1][12] & ins_and_outs[12]) |
        (ins_pla_ors[1][13] & ins_and_outs[13]) |
        (ins_pla_ors[1][14] & ins_and_outs[14]) |
        (ins_pla_ors[1][15] & ins_and_outs[15]) |
        (ins_pla_ors[1][16] & ins_and_outs[16]) |
        (ins_pla_ors[1][17] & ins_and_outs[17]) |
        (ins_pla_ors[1][18] & ins_and_outs[18]) |
        (ins_pla_ors[1][19] & ins_and_outs[19]) |
        (ins_pla_ors[1][20] & ins_and_outs[20]) |
        (ins_pla_ors[1][21] & ins_and_outs[21]) |
        (ins_pla_ors[1][22] & ins_and_outs[22]) |
        (ins_pla_ors[1][23] & ins_and_outs[23]) |
        (ins_pla_ors[1][24] & ins_and_outs[24]) |
        (ins_pla_ors[1][25] & ins_and_outs[25]) |
        (ins_pla_ors[1][26] & ins_and_outs[26]) |
        (ins_pla_ors[1][27] & ins_and_outs[27]) |
        (ins_pla_ors[1][28] & ins_and_outs[28]) |
        (ins_pla_ors[1][29] & ins_and_outs[29]),
    (ins_pla_ors[0][0] & ins_and_outs[0]) |
        (ins_pla_ors[0][1] & ins_and_outs[1]) |
        (ins_pla_ors[0][2] & ins_and_outs[2]) |
        (ins_pla_ors[0][3] & ins_and_outs[3]) |
        (ins_pla_ors[0][4] & ins_and_outs[4]) |
        (ins_pla_ors[0][5] & ins_and_outs[5]) |
        (ins_pla_ors[0][6] & ins_and_outs[6]) |
        (ins_pla_ors[0][7] & ins_and_outs[7]) |
        (ins_pla_ors[0][8] & ins_and_outs[8]) |
        (ins_pla_ors[0][9] & ins_and_outs[9]) |
        (ins_pla_ors[0][10] & ins_and_outs[10]) |
        (ins_pla_ors[0][11] & ins_and_outs[11]) |
        (ins_pla_ors[0][12] & ins_and_outs[12]) |
        (ins_pla_ors[0][13] & ins_and_outs[13]) |
        (ins_pla_ors[0][14] & ins_and_outs[14]) |
        (ins_pla_ors[0][15] & ins_and_outs[15]) |
        (ins_pla_ors[0][16] & ins_and_outs[16]) |
        (ins_pla_ors[0][17] & ins_and_outs[17]) |
        (ins_pla_ors[0][18] & ins_and_outs[18]) |
        (ins_pla_ors[0][19] & ins_and_outs[19]) |
        (ins_pla_ors[0][20] & ins_and_outs[20]) |
        (ins_pla_ors[0][21] & ins_and_outs[21]) |
        (ins_pla_ors[0][22] & ins_and_outs[22]) |
        (ins_pla_ors[0][23] & ins_and_outs[23]) |
        (ins_pla_ors[0][24] & ins_and_outs[24]) |
        (ins_pla_ors[0][25] & ins_and_outs[25]) |
        (ins_pla_ors[0][26] & ins_and_outs[26]) |
        (ins_pla_ors[0][27] & ins_and_outs[27]) |
        (ins_pla_ors[0][28] & ins_and_outs[28]) |
        (ins_pla_ors[0][29] & ins_and_outs[29])
};

/*#endregion*/

/*always @(*) begin
	for(i = 0; i < 31; i++) begin
		and_outs[i] = 0;
		for(j = 0; j < 16; j++) begin
			and_outs[i] = and_outs[i] & pla_ins[j] & ins_pla_ands[i][j];
		end
	end

	for(i = 0; i < 31; i++) begin
		for(j = 0; j < 16; j++) begin
			or_outs[j] = or_outs[j] | (ins_pla_ors[i] & and_outs[i]);
		end
	end
end*/

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
wire [5:0] next_pc = PC + 1; //Temp until I figure out the weird PC update logic
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
reg [3:0] RAM [255:0];
wire [3:0] ram_r = RAM[ram_addr_buff];
//wire [3:0] ram_r_bclr = ram_r & ~(1 << ins_arg[7:6]);
//wire [3:0] ram_r_bset = ram_r | (1 << ins_arg[7:6]);

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
                    ins_pla_ands[pla_addr[4:0]] = pla_val[15:0];
                end
                1: begin
                    ins_pla_ors[pla_addr[3:0]] = pla_val[29:0];
                end
                2: begin
                    O_pla_ands[pla_addr[4:0]] = pla_val[9:0];
                end
                3: begin
                    O_pla_ors[pla_addr[2:0]] = pla_val[19:0];
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
				P <= (YTP ? Y : 0) | (MTP ? ram_r : 0) | (CKP ? CKI_bus : 0);
				N <= (ATN ? A : 0) | (NATN ? ~A : 0) | (MTN ? ram_r : 0) | (FIFTEENTN ? 15 : 0) | (CKN ? CKI_bus : 0);
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
				if(RBIT) begin
					RAM[ram_addr_buff] <= ram_r & bmask;
				end
				if(SBIT) begin
					RAM[ram_addr_buff] <= ram_r | ~bmask;
				end
				if(SETR) begin
					R_latch[Y] <= 1; //actually restrict this to 12 bits if in TMS1000 mode
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
		if(phi_five && (STO || CKM)) begin
			//Write RAM
			RAM[ram_addr_buff] <= (STO ? A : 0) | (CKM ? CKI_bus : 0);
		end
	end
end

endmodule
