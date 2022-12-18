// This is the unpowered netlist.
module user_project_wrapper (user_clock2,
    wb_clk_i,
    wb_rst_i,
    wbs_ack_o,
    wbs_cyc_i,
    wbs_stb_i,
    wbs_we_i,
    analog_io,
    io_in,
    io_oeb,
    io_out,
    la_data_in,
    la_data_out,
    la_oenb,
    user_irq,
    wbs_adr_i,
    wbs_dat_i,
    wbs_dat_o,
    wbs_sel_i);
 input user_clock2;
 input wb_clk_i;
 input wb_rst_i;
 output wbs_ack_o;
 input wbs_cyc_i;
 input wbs_stb_i;
 input wbs_we_i;
 inout [28:0] analog_io;
 input [37:0] io_in;
 output [37:0] io_oeb;
 output [37:0] io_out;
 input [127:0] la_data_in;
 output [127:0] la_data_out;
 input [127:0] la_oenb;
 output [2:0] user_irq;
 input [31:0] wbs_adr_i;
 input [31:0] wbs_dat_i;
 output [31:0] wbs_dat_o;
 input [3:0] wbs_sel_i;

 wire \oram_addr[0] ;
 wire \oram_addr[1] ;
 wire \oram_addr[2] ;
 wire \oram_addr[3] ;
 wire \oram_addr[4] ;
 wire \oram_addr[5] ;
 wire \oram_addr[6] ;
 wire \oram_addr[7] ;
 wire \oram_addr[8] ;
 wire \oram_value[0] ;
 wire \oram_value[10] ;
 wire \oram_value[11] ;
 wire \oram_value[12] ;
 wire \oram_value[13] ;
 wire \oram_value[14] ;
 wire \oram_value[15] ;
 wire \oram_value[16] ;
 wire \oram_value[17] ;
 wire \oram_value[18] ;
 wire \oram_value[19] ;
 wire \oram_value[1] ;
 wire \oram_value[20] ;
 wire \oram_value[21] ;
 wire \oram_value[22] ;
 wire \oram_value[23] ;
 wire \oram_value[24] ;
 wire \oram_value[25] ;
 wire \oram_value[26] ;
 wire \oram_value[27] ;
 wire \oram_value[28] ;
 wire \oram_value[29] ;
 wire \oram_value[2] ;
 wire \oram_value[30] ;
 wire \oram_value[31] ;
 wire \oram_value[3] ;
 wire \oram_value[4] ;
 wire \oram_value[5] ;
 wire \oram_value[6] ;
 wire \oram_value[7] ;
 wire \oram_value[8] ;
 wire \oram_value[9] ;

 wrapped_tms1x00 wrapped_tms1x00 (.wb_clk_i(wb_clk_i),
    .wb_rst_i(wb_rst_i),
    .io_in({io_in[37],
    io_in[36],
    io_in[35],
    io_in[34],
    io_in[33],
    io_in[32],
    io_in[31],
    io_in[30],
    io_in[29],
    io_in[28],
    io_in[27],
    io_in[26],
    io_in[25],
    io_in[24],
    io_in[23],
    io_in[22],
    io_in[21],
    io_in[20],
    io_in[19],
    io_in[18],
    io_in[17],
    io_in[16],
    io_in[15],
    io_in[14],
    io_in[13],
    io_in[12],
    io_in[11],
    io_in[10],
    io_in[9],
    io_in[8],
    io_in[7],
    io_in[6],
    io_in[5],
    io_in[4],
    io_in[3],
    io_in[2],
    io_in[1],
    io_in[0]}),
    .io_oeb({io_oeb[37],
    io_oeb[36],
    io_oeb[35],
    io_oeb[34],
    io_oeb[33],
    io_oeb[32],
    io_oeb[31],
    io_oeb[30],
    io_oeb[29],
    io_oeb[28],
    io_oeb[27],
    io_oeb[26],
    io_oeb[25],
    io_oeb[24],
    io_oeb[23],
    io_oeb[22],
    io_oeb[21],
    io_oeb[20],
    io_oeb[19],
    io_oeb[18],
    io_oeb[17],
    io_oeb[16],
    io_oeb[15],
    io_oeb[14],
    io_oeb[13],
    io_oeb[12],
    io_oeb[11],
    io_oeb[10],
    io_oeb[9],
    io_oeb[8],
    io_oeb[7],
    io_oeb[6],
    io_oeb[5],
    io_oeb[4],
    io_oeb[3],
    io_oeb[2],
    io_oeb[1],
    io_oeb[0]}),
    .io_out({io_out[37],
    io_out[36],
    io_out[35],
    io_out[34],
    io_out[33],
    io_out[32],
    io_out[31],
    io_out[30],
    io_out[29],
    io_out[28],
    io_out[27],
    io_out[26],
    io_out[25],
    io_out[24],
    io_out[23],
    io_out[22],
    io_out[21],
    io_out[20],
    io_out[19],
    io_out[18],
    io_out[17],
    io_out[16],
    io_out[15],
    io_out[14],
    io_out[13],
    io_out[12],
    io_out[11],
    io_out[10],
    io_out[9],
    io_out[8],
    io_out[7],
    io_out[6],
    io_out[5],
    io_out[4],
    io_out[3],
    io_out[2],
    io_out[1],
    io_out[0]}),
    .oram_addr({\oram_addr[8] ,
    \oram_addr[7] ,
    \oram_addr[6] ,
    \oram_addr[5] ,
    \oram_addr[4] ,
    \oram_addr[3] ,
    \oram_addr[2] ,
    \oram_addr[1] ,
    \oram_addr[0] }),
    .oram_value({\oram_value[31] ,
    \oram_value[30] ,
    \oram_value[29] ,
    \oram_value[28] ,
    \oram_value[27] ,
    \oram_value[26] ,
    \oram_value[25] ,
    \oram_value[24] ,
    \oram_value[23] ,
    \oram_value[22] ,
    \oram_value[21] ,
    \oram_value[20] ,
    \oram_value[19] ,
    \oram_value[18] ,
    \oram_value[17] ,
    \oram_value[16] ,
    \oram_value[15] ,
    \oram_value[14] ,
    \oram_value[13] ,
    \oram_value[12] ,
    \oram_value[11] ,
    \oram_value[10] ,
    \oram_value[9] ,
    \oram_value[8] ,
    \oram_value[7] ,
    \oram_value[6] ,
    \oram_value[5] ,
    \oram_value[4] ,
    \oram_value[3] ,
    \oram_value[2] ,
    \oram_value[1] ,
    \oram_value[0] }));
endmodule

