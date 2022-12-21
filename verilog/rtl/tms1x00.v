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
	input [7:0] rom_value,

    output chip_sel_o,

    /* Wishbone overrides */
    input wb_override,
    input wb_step
);

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
reg CL;         //Call Latch

//I/Os
reg [4:0] O_latch;
reg [15:0] R_latch;
reg [3:0] K_latch;

reg [2:0] cycle;
reg [7:0] ins_in;
reg [15:0] ins_pla_ands [29:0];
reg [29:0] ins_pla_ors [15:0];

reg chip_sel;
assign chip_sel_o = chip_sel;

assign O_out = {cycle, O_latch};
assign R_out = R_latch;

/* Instruction decoding */

/*#region PLA*/

wire [15:0] pla_ins = {
    ins_in[0],
    ~ins_in[0],
    ins_in[1],
    ~ins_in[1],
    ins_in[2],
    ~ins_in[2],
    ins_in[3],
    ~ins_in[3],
    ins_in[4],
    ~ins_in[4],
    ins_in[5],
    ~ins_in[5],
    ins_in[6],
    ~ins_in[6],
    ins_in[7],
    ~ins_in[7]
};

wire [29:0] and_outs = {
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
        (pla_ins[15] | ~ins_pla_ands[0][15]),
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
        (pla_ins[15] | ~ins_pla_ands[29][15])
};

wire [15:0] or_outs = {
    (ins_pla_ors[0][0] & and_outs[0]) |
        (ins_pla_ors[0][1] & and_outs[0]) |
        (ins_pla_ors[0][2] & and_outs[0]) |
        (ins_pla_ors[0][3] & and_outs[0]) |
        (ins_pla_ors[0][4] & and_outs[0]) |
        (ins_pla_ors[0][5] & and_outs[0]) |
        (ins_pla_ors[0][6] & and_outs[0]) |
        (ins_pla_ors[0][7] & and_outs[0]) |
        (ins_pla_ors[0][8] & and_outs[0]) |
        (ins_pla_ors[0][9] & and_outs[0]) |
        (ins_pla_ors[0][10] & and_outs[0]) |
        (ins_pla_ors[0][11] & and_outs[0]) |
        (ins_pla_ors[0][12] & and_outs[0]) |
        (ins_pla_ors[0][13] & and_outs[0]) |
        (ins_pla_ors[0][14] & and_outs[0]) |
        (ins_pla_ors[0][15] & and_outs[0]) |
        (ins_pla_ors[0][16] & and_outs[0]) |
        (ins_pla_ors[0][17] & and_outs[0]) |
        (ins_pla_ors[0][18] & and_outs[0]) |
        (ins_pla_ors[0][19] & and_outs[0]) |
        (ins_pla_ors[0][20] & and_outs[0]) |
        (ins_pla_ors[0][21] & and_outs[0]) |
        (ins_pla_ors[0][22] & and_outs[0]) |
        (ins_pla_ors[0][23] & and_outs[0]) |
        (ins_pla_ors[0][24] & and_outs[0]) |
        (ins_pla_ors[0][25] & and_outs[0]) |
        (ins_pla_ors[0][26] & and_outs[0]) |
        (ins_pla_ors[0][27] & and_outs[0]) |
        (ins_pla_ors[0][28] & and_outs[0]) |
        (ins_pla_ors[0][29] & and_outs[0]),
    (ins_pla_ors[1][0] & and_outs[1]) |
        (ins_pla_ors[1][1] & and_outs[1]) |
        (ins_pla_ors[1][2] & and_outs[1]) |
        (ins_pla_ors[1][3] & and_outs[1]) |
        (ins_pla_ors[1][4] & and_outs[1]) |
        (ins_pla_ors[1][5] & and_outs[1]) |
        (ins_pla_ors[1][6] & and_outs[1]) |
        (ins_pla_ors[1][7] & and_outs[1]) |
        (ins_pla_ors[1][8] & and_outs[1]) |
        (ins_pla_ors[1][9] & and_outs[1]) |
        (ins_pla_ors[1][10] & and_outs[1]) |
        (ins_pla_ors[1][11] & and_outs[1]) |
        (ins_pla_ors[1][12] & and_outs[1]) |
        (ins_pla_ors[1][13] & and_outs[1]) |
        (ins_pla_ors[1][14] & and_outs[1]) |
        (ins_pla_ors[1][15] & and_outs[1]) |
        (ins_pla_ors[1][16] & and_outs[1]) |
        (ins_pla_ors[1][17] & and_outs[1]) |
        (ins_pla_ors[1][18] & and_outs[1]) |
        (ins_pla_ors[1][19] & and_outs[1]) |
        (ins_pla_ors[1][20] & and_outs[1]) |
        (ins_pla_ors[1][21] & and_outs[1]) |
        (ins_pla_ors[1][22] & and_outs[1]) |
        (ins_pla_ors[1][23] & and_outs[1]) |
        (ins_pla_ors[1][24] & and_outs[1]) |
        (ins_pla_ors[1][25] & and_outs[1]) |
        (ins_pla_ors[1][26] & and_outs[1]) |
        (ins_pla_ors[1][27] & and_outs[1]) |
        (ins_pla_ors[1][28] & and_outs[1]) |
        (ins_pla_ors[1][29] & and_outs[1]),
    (ins_pla_ors[2][0] & and_outs[2]) |
        (ins_pla_ors[2][1] & and_outs[2]) |
        (ins_pla_ors[2][2] & and_outs[2]) |
        (ins_pla_ors[2][3] & and_outs[2]) |
        (ins_pla_ors[2][4] & and_outs[2]) |
        (ins_pla_ors[2][5] & and_outs[2]) |
        (ins_pla_ors[2][6] & and_outs[2]) |
        (ins_pla_ors[2][7] & and_outs[2]) |
        (ins_pla_ors[2][8] & and_outs[2]) |
        (ins_pla_ors[2][9] & and_outs[2]) |
        (ins_pla_ors[2][10] & and_outs[2]) |
        (ins_pla_ors[2][11] & and_outs[2]) |
        (ins_pla_ors[2][12] & and_outs[2]) |
        (ins_pla_ors[2][13] & and_outs[2]) |
        (ins_pla_ors[2][14] & and_outs[2]) |
        (ins_pla_ors[2][15] & and_outs[2]) |
        (ins_pla_ors[2][16] & and_outs[2]) |
        (ins_pla_ors[2][17] & and_outs[2]) |
        (ins_pla_ors[2][18] & and_outs[2]) |
        (ins_pla_ors[2][19] & and_outs[2]) |
        (ins_pla_ors[2][20] & and_outs[2]) |
        (ins_pla_ors[2][21] & and_outs[2]) |
        (ins_pla_ors[2][22] & and_outs[2]) |
        (ins_pla_ors[2][23] & and_outs[2]) |
        (ins_pla_ors[2][24] & and_outs[2]) |
        (ins_pla_ors[2][25] & and_outs[2]) |
        (ins_pla_ors[2][26] & and_outs[2]) |
        (ins_pla_ors[2][27] & and_outs[2]) |
        (ins_pla_ors[2][28] & and_outs[2]) |
        (ins_pla_ors[2][29] & and_outs[2]),
    (ins_pla_ors[3][0] & and_outs[3]) |
        (ins_pla_ors[3][1] & and_outs[3]) |
        (ins_pla_ors[3][2] & and_outs[3]) |
        (ins_pla_ors[3][3] & and_outs[3]) |
        (ins_pla_ors[3][4] & and_outs[3]) |
        (ins_pla_ors[3][5] & and_outs[3]) |
        (ins_pla_ors[3][6] & and_outs[3]) |
        (ins_pla_ors[3][7] & and_outs[3]) |
        (ins_pla_ors[3][8] & and_outs[3]) |
        (ins_pla_ors[3][9] & and_outs[3]) |
        (ins_pla_ors[3][10] & and_outs[3]) |
        (ins_pla_ors[3][11] & and_outs[3]) |
        (ins_pla_ors[3][12] & and_outs[3]) |
        (ins_pla_ors[3][13] & and_outs[3]) |
        (ins_pla_ors[3][14] & and_outs[3]) |
        (ins_pla_ors[3][15] & and_outs[3]) |
        (ins_pla_ors[3][16] & and_outs[3]) |
        (ins_pla_ors[3][17] & and_outs[3]) |
        (ins_pla_ors[3][18] & and_outs[3]) |
        (ins_pla_ors[3][19] & and_outs[3]) |
        (ins_pla_ors[3][20] & and_outs[3]) |
        (ins_pla_ors[3][21] & and_outs[3]) |
        (ins_pla_ors[3][22] & and_outs[3]) |
        (ins_pla_ors[3][23] & and_outs[3]) |
        (ins_pla_ors[3][24] & and_outs[3]) |
        (ins_pla_ors[3][25] & and_outs[3]) |
        (ins_pla_ors[3][26] & and_outs[3]) |
        (ins_pla_ors[3][27] & and_outs[3]) |
        (ins_pla_ors[3][28] & and_outs[3]) |
        (ins_pla_ors[3][29] & and_outs[3]),
    (ins_pla_ors[4][0] & and_outs[4]) |
        (ins_pla_ors[4][1] & and_outs[4]) |
        (ins_pla_ors[4][2] & and_outs[4]) |
        (ins_pla_ors[4][3] & and_outs[4]) |
        (ins_pla_ors[4][4] & and_outs[4]) |
        (ins_pla_ors[4][5] & and_outs[4]) |
        (ins_pla_ors[4][6] & and_outs[4]) |
        (ins_pla_ors[4][7] & and_outs[4]) |
        (ins_pla_ors[4][8] & and_outs[4]) |
        (ins_pla_ors[4][9] & and_outs[4]) |
        (ins_pla_ors[4][10] & and_outs[4]) |
        (ins_pla_ors[4][11] & and_outs[4]) |
        (ins_pla_ors[4][12] & and_outs[4]) |
        (ins_pla_ors[4][13] & and_outs[4]) |
        (ins_pla_ors[4][14] & and_outs[4]) |
        (ins_pla_ors[4][15] & and_outs[4]) |
        (ins_pla_ors[4][16] & and_outs[4]) |
        (ins_pla_ors[4][17] & and_outs[4]) |
        (ins_pla_ors[4][18] & and_outs[4]) |
        (ins_pla_ors[4][19] & and_outs[4]) |
        (ins_pla_ors[4][20] & and_outs[4]) |
        (ins_pla_ors[4][21] & and_outs[4]) |
        (ins_pla_ors[4][22] & and_outs[4]) |
        (ins_pla_ors[4][23] & and_outs[4]) |
        (ins_pla_ors[4][24] & and_outs[4]) |
        (ins_pla_ors[4][25] & and_outs[4]) |
        (ins_pla_ors[4][26] & and_outs[4]) |
        (ins_pla_ors[4][27] & and_outs[4]) |
        (ins_pla_ors[4][28] & and_outs[4]) |
        (ins_pla_ors[4][29] & and_outs[4]),
    (ins_pla_ors[5][0] & and_outs[5]) |
        (ins_pla_ors[5][1] & and_outs[5]) |
        (ins_pla_ors[5][2] & and_outs[5]) |
        (ins_pla_ors[5][3] & and_outs[5]) |
        (ins_pla_ors[5][4] & and_outs[5]) |
        (ins_pla_ors[5][5] & and_outs[5]) |
        (ins_pla_ors[5][6] & and_outs[5]) |
        (ins_pla_ors[5][7] & and_outs[5]) |
        (ins_pla_ors[5][8] & and_outs[5]) |
        (ins_pla_ors[5][9] & and_outs[5]) |
        (ins_pla_ors[5][10] & and_outs[5]) |
        (ins_pla_ors[5][11] & and_outs[5]) |
        (ins_pla_ors[5][12] & and_outs[5]) |
        (ins_pla_ors[5][13] & and_outs[5]) |
        (ins_pla_ors[5][14] & and_outs[5]) |
        (ins_pla_ors[5][15] & and_outs[5]) |
        (ins_pla_ors[5][16] & and_outs[5]) |
        (ins_pla_ors[5][17] & and_outs[5]) |
        (ins_pla_ors[5][18] & and_outs[5]) |
        (ins_pla_ors[5][19] & and_outs[5]) |
        (ins_pla_ors[5][20] & and_outs[5]) |
        (ins_pla_ors[5][21] & and_outs[5]) |
        (ins_pla_ors[5][22] & and_outs[5]) |
        (ins_pla_ors[5][23] & and_outs[5]) |
        (ins_pla_ors[5][24] & and_outs[5]) |
        (ins_pla_ors[5][25] & and_outs[5]) |
        (ins_pla_ors[5][26] & and_outs[5]) |
        (ins_pla_ors[5][27] & and_outs[5]) |
        (ins_pla_ors[5][28] & and_outs[5]) |
        (ins_pla_ors[5][29] & and_outs[5]),
    (ins_pla_ors[6][0] & and_outs[6]) |
        (ins_pla_ors[6][1] & and_outs[6]) |
        (ins_pla_ors[6][2] & and_outs[6]) |
        (ins_pla_ors[6][3] & and_outs[6]) |
        (ins_pla_ors[6][4] & and_outs[6]) |
        (ins_pla_ors[6][5] & and_outs[6]) |
        (ins_pla_ors[6][6] & and_outs[6]) |
        (ins_pla_ors[6][7] & and_outs[6]) |
        (ins_pla_ors[6][8] & and_outs[6]) |
        (ins_pla_ors[6][9] & and_outs[6]) |
        (ins_pla_ors[6][10] & and_outs[6]) |
        (ins_pla_ors[6][11] & and_outs[6]) |
        (ins_pla_ors[6][12] & and_outs[6]) |
        (ins_pla_ors[6][13] & and_outs[6]) |
        (ins_pla_ors[6][14] & and_outs[6]) |
        (ins_pla_ors[6][15] & and_outs[6]) |
        (ins_pla_ors[6][16] & and_outs[6]) |
        (ins_pla_ors[6][17] & and_outs[6]) |
        (ins_pla_ors[6][18] & and_outs[6]) |
        (ins_pla_ors[6][19] & and_outs[6]) |
        (ins_pla_ors[6][20] & and_outs[6]) |
        (ins_pla_ors[6][21] & and_outs[6]) |
        (ins_pla_ors[6][22] & and_outs[6]) |
        (ins_pla_ors[6][23] & and_outs[6]) |
        (ins_pla_ors[6][24] & and_outs[6]) |
        (ins_pla_ors[6][25] & and_outs[6]) |
        (ins_pla_ors[6][26] & and_outs[6]) |
        (ins_pla_ors[6][27] & and_outs[6]) |
        (ins_pla_ors[6][28] & and_outs[6]) |
        (ins_pla_ors[6][29] & and_outs[6]),
    (ins_pla_ors[7][0] & and_outs[7]) |
        (ins_pla_ors[7][1] & and_outs[7]) |
        (ins_pla_ors[7][2] & and_outs[7]) |
        (ins_pla_ors[7][3] & and_outs[7]) |
        (ins_pla_ors[7][4] & and_outs[7]) |
        (ins_pla_ors[7][5] & and_outs[7]) |
        (ins_pla_ors[7][6] & and_outs[7]) |
        (ins_pla_ors[7][7] & and_outs[7]) |
        (ins_pla_ors[7][8] & and_outs[7]) |
        (ins_pla_ors[7][9] & and_outs[7]) |
        (ins_pla_ors[7][10] & and_outs[7]) |
        (ins_pla_ors[7][11] & and_outs[7]) |
        (ins_pla_ors[7][12] & and_outs[7]) |
        (ins_pla_ors[7][13] & and_outs[7]) |
        (ins_pla_ors[7][14] & and_outs[7]) |
        (ins_pla_ors[7][15] & and_outs[7]) |
        (ins_pla_ors[7][16] & and_outs[7]) |
        (ins_pla_ors[7][17] & and_outs[7]) |
        (ins_pla_ors[7][18] & and_outs[7]) |
        (ins_pla_ors[7][19] & and_outs[7]) |
        (ins_pla_ors[7][20] & and_outs[7]) |
        (ins_pla_ors[7][21] & and_outs[7]) |
        (ins_pla_ors[7][22] & and_outs[7]) |
        (ins_pla_ors[7][23] & and_outs[7]) |
        (ins_pla_ors[7][24] & and_outs[7]) |
        (ins_pla_ors[7][25] & and_outs[7]) |
        (ins_pla_ors[7][26] & and_outs[7]) |
        (ins_pla_ors[7][27] & and_outs[7]) |
        (ins_pla_ors[7][28] & and_outs[7]) |
        (ins_pla_ors[7][29] & and_outs[7]),
    (ins_pla_ors[8][0] & and_outs[8]) |
        (ins_pla_ors[8][1] & and_outs[8]) |
        (ins_pla_ors[8][2] & and_outs[8]) |
        (ins_pla_ors[8][3] & and_outs[8]) |
        (ins_pla_ors[8][4] & and_outs[8]) |
        (ins_pla_ors[8][5] & and_outs[8]) |
        (ins_pla_ors[8][6] & and_outs[8]) |
        (ins_pla_ors[8][7] & and_outs[8]) |
        (ins_pla_ors[8][8] & and_outs[8]) |
        (ins_pla_ors[8][9] & and_outs[8]) |
        (ins_pla_ors[8][10] & and_outs[8]) |
        (ins_pla_ors[8][11] & and_outs[8]) |
        (ins_pla_ors[8][12] & and_outs[8]) |
        (ins_pla_ors[8][13] & and_outs[8]) |
        (ins_pla_ors[8][14] & and_outs[8]) |
        (ins_pla_ors[8][15] & and_outs[8]) |
        (ins_pla_ors[8][16] & and_outs[8]) |
        (ins_pla_ors[8][17] & and_outs[8]) |
        (ins_pla_ors[8][18] & and_outs[8]) |
        (ins_pla_ors[8][19] & and_outs[8]) |
        (ins_pla_ors[8][20] & and_outs[8]) |
        (ins_pla_ors[8][21] & and_outs[8]) |
        (ins_pla_ors[8][22] & and_outs[8]) |
        (ins_pla_ors[8][23] & and_outs[8]) |
        (ins_pla_ors[8][24] & and_outs[8]) |
        (ins_pla_ors[8][25] & and_outs[8]) |
        (ins_pla_ors[8][26] & and_outs[8]) |
        (ins_pla_ors[8][27] & and_outs[8]) |
        (ins_pla_ors[8][28] & and_outs[8]) |
        (ins_pla_ors[8][29] & and_outs[8]),
    (ins_pla_ors[9][0] & and_outs[9]) |
        (ins_pla_ors[9][1] & and_outs[9]) |
        (ins_pla_ors[9][2] & and_outs[9]) |
        (ins_pla_ors[9][3] & and_outs[9]) |
        (ins_pla_ors[9][4] & and_outs[9]) |
        (ins_pla_ors[9][5] & and_outs[9]) |
        (ins_pla_ors[9][6] & and_outs[9]) |
        (ins_pla_ors[9][7] & and_outs[9]) |
        (ins_pla_ors[9][8] & and_outs[9]) |
        (ins_pla_ors[9][9] & and_outs[9]) |
        (ins_pla_ors[9][10] & and_outs[9]) |
        (ins_pla_ors[9][11] & and_outs[9]) |
        (ins_pla_ors[9][12] & and_outs[9]) |
        (ins_pla_ors[9][13] & and_outs[9]) |
        (ins_pla_ors[9][14] & and_outs[9]) |
        (ins_pla_ors[9][15] & and_outs[9]) |
        (ins_pla_ors[9][16] & and_outs[9]) |
        (ins_pla_ors[9][17] & and_outs[9]) |
        (ins_pla_ors[9][18] & and_outs[9]) |
        (ins_pla_ors[9][19] & and_outs[9]) |
        (ins_pla_ors[9][20] & and_outs[9]) |
        (ins_pla_ors[9][21] & and_outs[9]) |
        (ins_pla_ors[9][22] & and_outs[9]) |
        (ins_pla_ors[9][23] & and_outs[9]) |
        (ins_pla_ors[9][24] & and_outs[9]) |
        (ins_pla_ors[9][25] & and_outs[9]) |
        (ins_pla_ors[9][26] & and_outs[9]) |
        (ins_pla_ors[9][27] & and_outs[9]) |
        (ins_pla_ors[9][28] & and_outs[9]) |
        (ins_pla_ors[9][29] & and_outs[9]),
    (ins_pla_ors[10][0] & and_outs[10]) |
        (ins_pla_ors[10][1] & and_outs[10]) |
        (ins_pla_ors[10][2] & and_outs[10]) |
        (ins_pla_ors[10][3] & and_outs[10]) |
        (ins_pla_ors[10][4] & and_outs[10]) |
        (ins_pla_ors[10][5] & and_outs[10]) |
        (ins_pla_ors[10][6] & and_outs[10]) |
        (ins_pla_ors[10][7] & and_outs[10]) |
        (ins_pla_ors[10][8] & and_outs[10]) |
        (ins_pla_ors[10][9] & and_outs[10]) |
        (ins_pla_ors[10][10] & and_outs[10]) |
        (ins_pla_ors[10][11] & and_outs[10]) |
        (ins_pla_ors[10][12] & and_outs[10]) |
        (ins_pla_ors[10][13] & and_outs[10]) |
        (ins_pla_ors[10][14] & and_outs[10]) |
        (ins_pla_ors[10][15] & and_outs[10]) |
        (ins_pla_ors[10][16] & and_outs[10]) |
        (ins_pla_ors[10][17] & and_outs[10]) |
        (ins_pla_ors[10][18] & and_outs[10]) |
        (ins_pla_ors[10][19] & and_outs[10]) |
        (ins_pla_ors[10][20] & and_outs[10]) |
        (ins_pla_ors[10][21] & and_outs[10]) |
        (ins_pla_ors[10][22] & and_outs[10]) |
        (ins_pla_ors[10][23] & and_outs[10]) |
        (ins_pla_ors[10][24] & and_outs[10]) |
        (ins_pla_ors[10][25] & and_outs[10]) |
        (ins_pla_ors[10][26] & and_outs[10]) |
        (ins_pla_ors[10][27] & and_outs[10]) |
        (ins_pla_ors[10][28] & and_outs[10]) |
        (ins_pla_ors[10][29] & and_outs[10]),
    (ins_pla_ors[11][0] & and_outs[11]) |
        (ins_pla_ors[11][1] & and_outs[11]) |
        (ins_pla_ors[11][2] & and_outs[11]) |
        (ins_pla_ors[11][3] & and_outs[11]) |
        (ins_pla_ors[11][4] & and_outs[11]) |
        (ins_pla_ors[11][5] & and_outs[11]) |
        (ins_pla_ors[11][6] & and_outs[11]) |
        (ins_pla_ors[11][7] & and_outs[11]) |
        (ins_pla_ors[11][8] & and_outs[11]) |
        (ins_pla_ors[11][9] & and_outs[11]) |
        (ins_pla_ors[11][10] & and_outs[11]) |
        (ins_pla_ors[11][11] & and_outs[11]) |
        (ins_pla_ors[11][12] & and_outs[11]) |
        (ins_pla_ors[11][13] & and_outs[11]) |
        (ins_pla_ors[11][14] & and_outs[11]) |
        (ins_pla_ors[11][15] & and_outs[11]) |
        (ins_pla_ors[11][16] & and_outs[11]) |
        (ins_pla_ors[11][17] & and_outs[11]) |
        (ins_pla_ors[11][18] & and_outs[11]) |
        (ins_pla_ors[11][19] & and_outs[11]) |
        (ins_pla_ors[11][20] & and_outs[11]) |
        (ins_pla_ors[11][21] & and_outs[11]) |
        (ins_pla_ors[11][22] & and_outs[11]) |
        (ins_pla_ors[11][23] & and_outs[11]) |
        (ins_pla_ors[11][24] & and_outs[11]) |
        (ins_pla_ors[11][25] & and_outs[11]) |
        (ins_pla_ors[11][26] & and_outs[11]) |
        (ins_pla_ors[11][27] & and_outs[11]) |
        (ins_pla_ors[11][28] & and_outs[11]) |
        (ins_pla_ors[11][29] & and_outs[11]),
    (ins_pla_ors[12][0] & and_outs[12]) |
        (ins_pla_ors[12][1] & and_outs[12]) |
        (ins_pla_ors[12][2] & and_outs[12]) |
        (ins_pla_ors[12][3] & and_outs[12]) |
        (ins_pla_ors[12][4] & and_outs[12]) |
        (ins_pla_ors[12][5] & and_outs[12]) |
        (ins_pla_ors[12][6] & and_outs[12]) |
        (ins_pla_ors[12][7] & and_outs[12]) |
        (ins_pla_ors[12][8] & and_outs[12]) |
        (ins_pla_ors[12][9] & and_outs[12]) |
        (ins_pla_ors[12][10] & and_outs[12]) |
        (ins_pla_ors[12][11] & and_outs[12]) |
        (ins_pla_ors[12][12] & and_outs[12]) |
        (ins_pla_ors[12][13] & and_outs[12]) |
        (ins_pla_ors[12][14] & and_outs[12]) |
        (ins_pla_ors[12][15] & and_outs[12]) |
        (ins_pla_ors[12][16] & and_outs[12]) |
        (ins_pla_ors[12][17] & and_outs[12]) |
        (ins_pla_ors[12][18] & and_outs[12]) |
        (ins_pla_ors[12][19] & and_outs[12]) |
        (ins_pla_ors[12][20] & and_outs[12]) |
        (ins_pla_ors[12][21] & and_outs[12]) |
        (ins_pla_ors[12][22] & and_outs[12]) |
        (ins_pla_ors[12][23] & and_outs[12]) |
        (ins_pla_ors[12][24] & and_outs[12]) |
        (ins_pla_ors[12][25] & and_outs[12]) |
        (ins_pla_ors[12][26] & and_outs[12]) |
        (ins_pla_ors[12][27] & and_outs[12]) |
        (ins_pla_ors[12][28] & and_outs[12]) |
        (ins_pla_ors[12][29] & and_outs[12]),
    (ins_pla_ors[13][0] & and_outs[13]) |
        (ins_pla_ors[13][1] & and_outs[13]) |
        (ins_pla_ors[13][2] & and_outs[13]) |
        (ins_pla_ors[13][3] & and_outs[13]) |
        (ins_pla_ors[13][4] & and_outs[13]) |
        (ins_pla_ors[13][5] & and_outs[13]) |
        (ins_pla_ors[13][6] & and_outs[13]) |
        (ins_pla_ors[13][7] & and_outs[13]) |
        (ins_pla_ors[13][8] & and_outs[13]) |
        (ins_pla_ors[13][9] & and_outs[13]) |
        (ins_pla_ors[13][10] & and_outs[13]) |
        (ins_pla_ors[13][11] & and_outs[13]) |
        (ins_pla_ors[13][12] & and_outs[13]) |
        (ins_pla_ors[13][13] & and_outs[13]) |
        (ins_pla_ors[13][14] & and_outs[13]) |
        (ins_pla_ors[13][15] & and_outs[13]) |
        (ins_pla_ors[13][16] & and_outs[13]) |
        (ins_pla_ors[13][17] & and_outs[13]) |
        (ins_pla_ors[13][18] & and_outs[13]) |
        (ins_pla_ors[13][19] & and_outs[13]) |
        (ins_pla_ors[13][20] & and_outs[13]) |
        (ins_pla_ors[13][21] & and_outs[13]) |
        (ins_pla_ors[13][22] & and_outs[13]) |
        (ins_pla_ors[13][23] & and_outs[13]) |
        (ins_pla_ors[13][24] & and_outs[13]) |
        (ins_pla_ors[13][25] & and_outs[13]) |
        (ins_pla_ors[13][26] & and_outs[13]) |
        (ins_pla_ors[13][27] & and_outs[13]) |
        (ins_pla_ors[13][28] & and_outs[13]) |
        (ins_pla_ors[13][29] & and_outs[13]),
    (ins_pla_ors[14][0] & and_outs[14]) |
        (ins_pla_ors[14][1] & and_outs[14]) |
        (ins_pla_ors[14][2] & and_outs[14]) |
        (ins_pla_ors[14][3] & and_outs[14]) |
        (ins_pla_ors[14][4] & and_outs[14]) |
        (ins_pla_ors[14][5] & and_outs[14]) |
        (ins_pla_ors[14][6] & and_outs[14]) |
        (ins_pla_ors[14][7] & and_outs[14]) |
        (ins_pla_ors[14][8] & and_outs[14]) |
        (ins_pla_ors[14][9] & and_outs[14]) |
        (ins_pla_ors[14][10] & and_outs[14]) |
        (ins_pla_ors[14][11] & and_outs[14]) |
        (ins_pla_ors[14][12] & and_outs[14]) |
        (ins_pla_ors[14][13] & and_outs[14]) |
        (ins_pla_ors[14][14] & and_outs[14]) |
        (ins_pla_ors[14][15] & and_outs[14]) |
        (ins_pla_ors[14][16] & and_outs[14]) |
        (ins_pla_ors[14][17] & and_outs[14]) |
        (ins_pla_ors[14][18] & and_outs[14]) |
        (ins_pla_ors[14][19] & and_outs[14]) |
        (ins_pla_ors[14][20] & and_outs[14]) |
        (ins_pla_ors[14][21] & and_outs[14]) |
        (ins_pla_ors[14][22] & and_outs[14]) |
        (ins_pla_ors[14][23] & and_outs[14]) |
        (ins_pla_ors[14][24] & and_outs[14]) |
        (ins_pla_ors[14][25] & and_outs[14]) |
        (ins_pla_ors[14][26] & and_outs[14]) |
        (ins_pla_ors[14][27] & and_outs[14]) |
        (ins_pla_ors[14][28] & and_outs[14]) |
        (ins_pla_ors[14][29] & and_outs[14]),
    (ins_pla_ors[15][0] & and_outs[15]) |
        (ins_pla_ors[15][1] & and_outs[15]) |
        (ins_pla_ors[15][2] & and_outs[15]) |
        (ins_pla_ors[15][3] & and_outs[15]) |
        (ins_pla_ors[15][4] & and_outs[15]) |
        (ins_pla_ors[15][5] & and_outs[15]) |
        (ins_pla_ors[15][6] & and_outs[15]) |
        (ins_pla_ors[15][7] & and_outs[15]) |
        (ins_pla_ors[15][8] & and_outs[15]) |
        (ins_pla_ors[15][9] & and_outs[15]) |
        (ins_pla_ors[15][10] & and_outs[15]) |
        (ins_pla_ors[15][11] & and_outs[15]) |
        (ins_pla_ors[15][12] & and_outs[15]) |
        (ins_pla_ors[15][13] & and_outs[15]) |
        (ins_pla_ors[15][14] & and_outs[15]) |
        (ins_pla_ors[15][15] & and_outs[15]) |
        (ins_pla_ors[15][16] & and_outs[15]) |
        (ins_pla_ors[15][17] & and_outs[15]) |
        (ins_pla_ors[15][18] & and_outs[15]) |
        (ins_pla_ors[15][19] & and_outs[15]) |
        (ins_pla_ors[15][20] & and_outs[15]) |
        (ins_pla_ors[15][21] & and_outs[15]) |
        (ins_pla_ors[15][22] & and_outs[15]) |
        (ins_pla_ors[15][23] & and_outs[15]) |
        (ins_pla_ors[15][24] & and_outs[15]) |
        (ins_pla_ors[15][25] & and_outs[15]) |
        (ins_pla_ors[15][26] & and_outs[15]) |
        (ins_pla_ors[15][27] & and_outs[15]) |
        (ins_pla_ors[15][28] & and_outs[15]) |
        (ins_pla_ors[15][29] & and_outs[15])
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

wire STO =	or_outs[0];
wire CKM =	or_outs[1];
wire CKP =	~or_outs[2];
wire YTP =	~or_outs[3];
wire MTP =	~or_outs[4];
wire ATN =	~or_outs[5];
wire NATN =	~or_outs[6];
wire MTN =	~or_outs[7];
wire FIFTEENTN = ~or_outs[8];
wire CKN =	~or_outs[9];
wire NE =	or_outs[10];
wire C8 =	or_outs[11];
wire CIN =	~or_outs[12];
wire AUTA =	or_outs[13];
wire AUTY =	or_outs[14];
wire STSL =	or_outs[15];

wire BR =	ins_in[7:6]	== 'b10;
wire CALL =	ins_in[7:6]	== 'b11;
wire CLO =	ins_in		== 'b00001011;
wire COMX =	ins_in		== 'b00000000;
wire LDP =	ins_in[7:4]	== 'b0001;
wire LDX =	ins_in[7:2]	== 'b001111;
wire RBIT =	ins_in[7:2]	== 'b001101;
wire RETN =	ins_in		== 'b00001111;
wire RSTR =	ins_in		== 'b00001100;
wire SBIT =	ins_in[7:2]	== 'b001100;
wire SETR =	ins_in		== 'b00001101;
wire TDO =	ins_in		== 'b00001010;

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
wire [6:0] ram_addr_new = {X[1:0], X[2], Y};
reg [3:0] RAM [255:0];
wire [3:0] ram_r = RAM[ram_addr_buff];
wire [3:0] ram_r_bclr = ram_r & ~(1 << ins_in[7:6]);
wire [3:0] ram_r_bset = ram_r | (1 << ins_in[7:6]);

/* ALU */
wire [4:0] adder_res = P + N + (CIN ? 1 : 0);
wire [3:0] alu_res = adder_res[3:0];
wire next_carry = adder_res[4];
wire comp_out = P == N;
wire alu_new_status = (NE ? ~comp_out : 1) & (C8 ? next_carry : 1);

/* CKI bus */
wire [3:0] CKI_bus = (ins_in <= 'h07 || (ins_in[7:4] >= 'h4 && ins_in[7:4] <= 'h7)) ? ins_in[7:4] : ((ins_in >= 'h08 && ins_in <= 'h0F) ? K_latch : 0);

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
		CB <= 0;
		Y <= 0;
		X <= 0;
		CL <= 0;
        wb_step_state <= 0;
        chip_sel <= chip_sel_i;
		ins_in <= 'h23; //TYA instruction. Something harmless to have as the first instruction.

        /*#region default_ins_pla_1000*/

        ins_pla_ands[0]  <= 'b1001010110101010;
        ins_pla_ands[1]  <= 'b0110100110101010;
        ins_pla_ands[2]  <= 'b1010100110101010;
        ins_pla_ands[3]  <= 'b0101011010101010;
        ins_pla_ands[4]  <= 'b1001011010101010;
        ins_pla_ands[5]  <= 'b1010011010101010;
        ins_pla_ands[6]  <= 'b0101101010101010;
        ins_pla_ands[7]  <= 'b1001101010101010;
        ins_pla_ands[8]  <= 'b0110001010101010;
        ins_pla_ands[9]  <= 'b0000100101011010;
        ins_pla_ands[10] <= 'b0101010110011010;
        ins_pla_ands[11] <= 'b1001010110011010;
        ins_pla_ands[12] <= 'b0110010110011010;
        ins_pla_ands[13] <= 'b1010010110011010;
        ins_pla_ands[14] <= 'b0101100110011010;
        ins_pla_ands[15] <= 'b1001100110011010;
        ins_pla_ands[16] <= 'b0110100110011010;
        ins_pla_ands[17] <= 'b1010100110011010;
        ins_pla_ands[18] <= 'b0101011010011010;
        ins_pla_ands[19] <= 'b1001011010011010;
        ins_pla_ands[20] <= 'b0110011010011010;
        ins_pla_ands[21] <= 'b1010011010011010;
        ins_pla_ands[22] <= 'b0101101010011010;
        ins_pla_ands[23] <= 'b1001101010011010;
        ins_pla_ands[24] <= 'b0110101010011010;
        ins_pla_ands[25] <= 'b1010101010011010;
        ins_pla_ands[26] <= 'b0000000001010110;
        ins_pla_ands[27] <= 'b0000000010010110;
        ins_pla_ands[28] <= 'b0000000001100110;
        ins_pla_ands[29] <= 'b0000000010100110;

        ins_pla_ors[0]  <= 'b000001100001000000000000010000;
        ins_pla_ors[1]  <= 'b000000000000000000000000000100;
        ins_pla_ors[2]  <= 'b100001110011111111111111110110;
        ins_pla_ors[3]  <= 'b111111101111100111111101101001;
        ins_pla_ors[4]  <= 'b111111111010111000000110011111;
        ins_pla_ors[5]  <= 'b011001100111111111110011111111;
        ins_pla_ors[6]  <= 'b111111111111011101011111110111;
        ins_pla_ors[7]  <= 'b111111111111111111111111111111;
        ins_pla_ors[8]  <= 'b111111111111101011111111111111;
        ins_pla_ors[9]  <= 'b111111111011111111111111111101;
        ins_pla_ors[10] <= 'b010000010100000000010000000010;
        ins_pla_ors[11] <= 'b000110001000111111101000001000;
        ins_pla_ors[12] <= 'b011011111111010100011111100011;
        ins_pla_ors[13] <= 'b101111001011100101101010100000;
        ins_pla_ors[14] <= 'b000000000000011000000101010101;
        ins_pla_ors[15] <= 'b000000010000000000000000000000;

        /*#endregion*/
	end else if(!wb_override || (wb_step != wb_step_state)) begin
        wb_step_state <= wb_step;
		cycle <= cycle + 1;
		if(cycle == 5) begin
			//Execute BR/CALL
			if(BR) begin
				if(status) begin
					PC <= ins_in[7:2];
					if(!CL) begin
						PA <= PB;
					end
				end
			end
			if(CALL) begin
				if(status) begin
					PC <= ins_in[7:2];
					if(CL) begin
						PB <= PA;
					end else begin
						SR <= PC;
						PB <= PA;
						PA <= PB;
						CL <= 1;
					end
				end
			end
			if(RETN) begin
				PA <= PB;
				if(CL) begin
					PC <= SR;
					CL <= 0;
				end
			end
			if(STSL) begin
				status <= alu_new_status;
			end else begin
				status <= 1;
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
				if(CLO) begin
					O_latch <= 0;
				end
				if(COMX) begin
					X <= ~X;
				end
				if(LDX) begin
					X <= ins_in[7:6];
				end
				if(RBIT) begin
					RAM[ram_addr_buff] <= ram_r_bclr;
				end
				if(SBIT) begin
					RAM[ram_addr_buff] <= ram_r_bset;
				end
				if(SETR) begin
					R_latch[Y] <= 1; //actually restrict this to 12 bits if in TMS1000 mode
				end
				if(RSTR) begin
					R_latch[Y] <= 0;
				end
				if(TDO) begin
					O_latch <= {status, A};
				end
				if(LDP) begin
					PB <= ins_in[7:4];
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
