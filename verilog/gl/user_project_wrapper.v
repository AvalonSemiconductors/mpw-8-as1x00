module user_project_wrapper (user_clock2,
    vccd1,
    vccd2,
    vdda1,
    vdda2,
    vssa1,
    vssa2,
    vssd1,
    vssd2,
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
 input vccd1;
 input vccd2;
 input vdda1;
 input vdda2;
 input vssa1;
 input vssa2;
 input vssd1;
 input vssd2;
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

 wire \ram_addr[0] ;
 wire \ram_addr[1] ;
 wire \ram_addr[2] ;
 wire \ram_addr[3] ;
 wire \ram_addr[4] ;
 wire \ram_addr[5] ;
 wire \ram_addr[6] ;
 wire \ram_val_in[0] ;
 wire \ram_val_in[1] ;
 wire \ram_val_in[2] ;
 wire \ram_val_in[3] ;
 wire \ram_val_out[0] ;
 wire \ram_val_out[1] ;
 wire \ram_val_out[2] ;
 wire \ram_val_out[3] ;
 wire ram_we;
 wire \rom_addr[0] ;
 wire \rom_addr[1] ;
 wire \rom_addr[2] ;
 wire \rom_addr[3] ;
 wire \rom_addr[4] ;
 wire \rom_addr[5] ;
 wire \rom_addr[6] ;
 wire \rom_addr[7] ;
 wire \rom_addr[8] ;
 wire rom_csb;
 wire \rom_value[0] ;
 wire \rom_value[10] ;
 wire \rom_value[11] ;
 wire \rom_value[12] ;
 wire \rom_value[13] ;
 wire \rom_value[14] ;
 wire \rom_value[15] ;
 wire \rom_value[16] ;
 wire \rom_value[17] ;
 wire \rom_value[18] ;
 wire \rom_value[19] ;
 wire \rom_value[1] ;
 wire \rom_value[20] ;
 wire \rom_value[21] ;
 wire \rom_value[22] ;
 wire \rom_value[23] ;
 wire \rom_value[24] ;
 wire \rom_value[25] ;
 wire \rom_value[26] ;
 wire \rom_value[27] ;
 wire \rom_value[28] ;
 wire \rom_value[29] ;
 wire \rom_value[2] ;
 wire \rom_value[30] ;
 wire \rom_value[31] ;
 wire \rom_value[3] ;
 wire \rom_value[4] ;
 wire \rom_value[5] ;
 wire \rom_value[6] ;
 wire \rom_value[7] ;
 wire \rom_value[8] ;
 wire \rom_value[9] ;
 wire \wb_rom_adrb[0] ;
 wire \wb_rom_adrb[1] ;
 wire \wb_rom_adrb[2] ;
 wire \wb_rom_adrb[3] ;
 wire \wb_rom_adrb[4] ;
 wire \wb_rom_adrb[5] ;
 wire \wb_rom_adrb[6] ;
 wire \wb_rom_adrb[7] ;
 wire \wb_rom_adrb[8] ;
 wire wb_rom_csb;
 wire \wb_rom_val[0] ;
 wire \wb_rom_val[10] ;
 wire \wb_rom_val[11] ;
 wire \wb_rom_val[12] ;
 wire \wb_rom_val[13] ;
 wire \wb_rom_val[14] ;
 wire \wb_rom_val[15] ;
 wire \wb_rom_val[16] ;
 wire \wb_rom_val[17] ;
 wire \wb_rom_val[18] ;
 wire \wb_rom_val[19] ;
 wire \wb_rom_val[1] ;
 wire \wb_rom_val[20] ;
 wire \wb_rom_val[21] ;
 wire \wb_rom_val[22] ;
 wire \wb_rom_val[23] ;
 wire \wb_rom_val[24] ;
 wire \wb_rom_val[25] ;
 wire \wb_rom_val[26] ;
 wire \wb_rom_val[27] ;
 wire \wb_rom_val[28] ;
 wire \wb_rom_val[29] ;
 wire \wb_rom_val[2] ;
 wire \wb_rom_val[30] ;
 wire \wb_rom_val[31] ;
 wire \wb_rom_val[3] ;
 wire \wb_rom_val[4] ;
 wire \wb_rom_val[5] ;
 wire \wb_rom_val[6] ;
 wire \wb_rom_val[7] ;
 wire \wb_rom_val[8] ;
 wire \wb_rom_val[9] ;
 wire wb_rom_web;

 sky130_sram_2kbyte_1rw1r_32x512_8 openram_2kB (.csb0(wb_rom_csb),
    .csb1(rom_csb),
    .web0(wb_rom_web),
    .clk0(wb_clk_i),
    .clk1(wb_clk_i),
    .vccd1(vccd1),
    .vssd1(vssd1),
    .addr0({\wb_rom_adrb[8] ,
    \wb_rom_adrb[7] ,
    \wb_rom_adrb[6] ,
    \wb_rom_adrb[5] ,
    \wb_rom_adrb[4] ,
    \wb_rom_adrb[3] ,
    \wb_rom_adrb[2] ,
    \wb_rom_adrb[1] ,
    \wb_rom_adrb[0] }),
    .addr1({\rom_addr[8] ,
    \rom_addr[7] ,
    \rom_addr[6] ,
    \rom_addr[5] ,
    \rom_addr[4] ,
    \rom_addr[3] ,
    \rom_addr[2] ,
    \rom_addr[1] ,
    \rom_addr[0] }),
    .din0({wbs_dat_i[31],
    wbs_dat_i[30],
    wbs_dat_i[29],
    wbs_dat_i[28],
    wbs_dat_i[27],
    wbs_dat_i[26],
    wbs_dat_i[25],
    wbs_dat_i[24],
    wbs_dat_i[23],
    wbs_dat_i[22],
    wbs_dat_i[21],
    wbs_dat_i[20],
    wbs_dat_i[19],
    wbs_dat_i[18],
    wbs_dat_i[17],
    wbs_dat_i[16],
    wbs_dat_i[15],
    wbs_dat_i[14],
    wbs_dat_i[13],
    wbs_dat_i[12],
    wbs_dat_i[11],
    wbs_dat_i[10],
    wbs_dat_i[9],
    wbs_dat_i[8],
    wbs_dat_i[7],
    wbs_dat_i[6],
    wbs_dat_i[5],
    wbs_dat_i[4],
    wbs_dat_i[3],
    wbs_dat_i[2],
    wbs_dat_i[1],
    wbs_dat_i[0]}),
    .dout0({\wb_rom_val[31] ,
    \wb_rom_val[30] ,
    \wb_rom_val[29] ,
    \wb_rom_val[28] ,
    \wb_rom_val[27] ,
    \wb_rom_val[26] ,
    \wb_rom_val[25] ,
    \wb_rom_val[24] ,
    \wb_rom_val[23] ,
    \wb_rom_val[22] ,
    \wb_rom_val[21] ,
    \wb_rom_val[20] ,
    \wb_rom_val[19] ,
    \wb_rom_val[18] ,
    \wb_rom_val[17] ,
    \wb_rom_val[16] ,
    \wb_rom_val[15] ,
    \wb_rom_val[14] ,
    \wb_rom_val[13] ,
    \wb_rom_val[12] ,
    \wb_rom_val[11] ,
    \wb_rom_val[10] ,
    \wb_rom_val[9] ,
    \wb_rom_val[8] ,
    \wb_rom_val[7] ,
    \wb_rom_val[6] ,
    \wb_rom_val[5] ,
    \wb_rom_val[4] ,
    \wb_rom_val[3] ,
    \wb_rom_val[2] ,
    \wb_rom_val[1] ,
    \wb_rom_val[0] }),
    .dout1({\rom_value[31] ,
    \rom_value[30] ,
    \rom_value[29] ,
    \rom_value[28] ,
    \rom_value[27] ,
    \rom_value[26] ,
    \rom_value[25] ,
    \rom_value[24] ,
    \rom_value[23] ,
    \rom_value[22] ,
    \rom_value[21] ,
    \rom_value[20] ,
    \rom_value[19] ,
    \rom_value[18] ,
    \rom_value[17] ,
    \rom_value[16] ,
    \rom_value[15] ,
    \rom_value[14] ,
    \rom_value[13] ,
    \rom_value[12] ,
    \rom_value[11] ,
    \rom_value[10] ,
    \rom_value[9] ,
    \rom_value[8] ,
    \rom_value[7] ,
    \rom_value[6] ,
    \rom_value[5] ,
    \rom_value[4] ,
    \rom_value[3] ,
    \rom_value[2] ,
    \rom_value[1] ,
    \rom_value[0] }),
    .wmask0({wbs_sel_i[3],
    wbs_sel_i[2],
    wbs_sel_i[1],
    wbs_sel_i[0]}));
 tms1x00_ram ram (.clk(wb_clk_i),
    .vccd1(vccd1),
    .vssd1(vssd1),
    .wen(ram_we),
    .r_val({\ram_val_in[3] ,
    \ram_val_in[2] ,
    \ram_val_in[1] ,
    \ram_val_in[0] }),
    .ram_addr({\ram_addr[6] ,
    \ram_addr[5] ,
    \ram_addr[4] ,
    \ram_addr[3] ,
    \ram_addr[2] ,
    \ram_addr[1] ,
    \ram_addr[0] }),
    .w_val({\ram_val_out[3] ,
    \ram_val_out[2] ,
    \ram_val_out[1] ,
    \ram_val_out[0] }));
 wrapped_tms1x00 wrapped_tms1x00 (.ram_we(ram_we),
    .rom_csb(rom_csb),
    .vccd1(vccd1),
    .vssd1(vssd1),
    .wb_clk_i(wb_clk_i),
    .wb_rom_csb(wb_rom_csb),
    .wb_rom_web(wb_rom_web),
    .wb_rst_i(wb_rst_i),
    .wbs_ack_o(wbs_ack_o),
    .wbs_cyc_i(wbs_cyc_i),
    .wbs_stb_i(wbs_stb_i),
    .wbs_we_i(wbs_we_i),
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
    .ram_addr({\ram_addr[6] ,
    \ram_addr[5] ,
    \ram_addr[4] ,
    \ram_addr[3] ,
    \ram_addr[2] ,
    \ram_addr[1] ,
    \ram_addr[0] }),
    .ram_val_in({\ram_val_in[3] ,
    \ram_val_in[2] ,
    \ram_val_in[1] ,
    \ram_val_in[0] }),
    .ram_val_out({\ram_val_out[3] ,
    \ram_val_out[2] ,
    \ram_val_out[1] ,
    \ram_val_out[0] }),
    .rom_addr({\rom_addr[8] ,
    \rom_addr[7] ,
    \rom_addr[6] ,
    \rom_addr[5] ,
    \rom_addr[4] ,
    \rom_addr[3] ,
    \rom_addr[2] ,
    \rom_addr[1] ,
    \rom_addr[0] }),
    .rom_value({\rom_value[31] ,
    \rom_value[30] ,
    \rom_value[29] ,
    \rom_value[28] ,
    \rom_value[27] ,
    \rom_value[26] ,
    \rom_value[25] ,
    \rom_value[24] ,
    \rom_value[23] ,
    \rom_value[22] ,
    \rom_value[21] ,
    \rom_value[20] ,
    \rom_value[19] ,
    \rom_value[18] ,
    \rom_value[17] ,
    \rom_value[16] ,
    \rom_value[15] ,
    \rom_value[14] ,
    \rom_value[13] ,
    \rom_value[12] ,
    \rom_value[11] ,
    \rom_value[10] ,
    \rom_value[9] ,
    \rom_value[8] ,
    \rom_value[7] ,
    \rom_value[6] ,
    \rom_value[5] ,
    \rom_value[4] ,
    \rom_value[3] ,
    \rom_value[2] ,
    \rom_value[1] ,
    \rom_value[0] }),
    .wb_rom_adrb({\wb_rom_adrb[8] ,
    \wb_rom_adrb[7] ,
    \wb_rom_adrb[6] ,
    \wb_rom_adrb[5] ,
    \wb_rom_adrb[4] ,
    \wb_rom_adrb[3] ,
    \wb_rom_adrb[2] ,
    \wb_rom_adrb[1] ,
    \wb_rom_adrb[0] }),
    .wb_rom_val({\wb_rom_val[31] ,
    \wb_rom_val[30] ,
    \wb_rom_val[29] ,
    \wb_rom_val[28] ,
    \wb_rom_val[27] ,
    \wb_rom_val[26] ,
    \wb_rom_val[25] ,
    \wb_rom_val[24] ,
    \wb_rom_val[23] ,
    \wb_rom_val[22] ,
    \wb_rom_val[21] ,
    \wb_rom_val[20] ,
    \wb_rom_val[19] ,
    \wb_rom_val[18] ,
    \wb_rom_val[17] ,
    \wb_rom_val[16] ,
    \wb_rom_val[15] ,
    \wb_rom_val[14] ,
    \wb_rom_val[13] ,
    \wb_rom_val[12] ,
    \wb_rom_val[11] ,
    \wb_rom_val[10] ,
    \wb_rom_val[9] ,
    \wb_rom_val[8] ,
    \wb_rom_val[7] ,
    \wb_rom_val[6] ,
    \wb_rom_val[5] ,
    \wb_rom_val[4] ,
    \wb_rom_val[3] ,
    \wb_rom_val[2] ,
    \wb_rom_val[1] ,
    \wb_rom_val[0] }),
    .wbs_adr_i({wbs_adr_i[31],
    wbs_adr_i[30],
    wbs_adr_i[29],
    wbs_adr_i[28],
    wbs_adr_i[27],
    wbs_adr_i[26],
    wbs_adr_i[25],
    wbs_adr_i[24],
    wbs_adr_i[23],
    wbs_adr_i[22],
    wbs_adr_i[21],
    wbs_adr_i[20],
    wbs_adr_i[19],
    wbs_adr_i[18],
    wbs_adr_i[17],
    wbs_adr_i[16],
    wbs_adr_i[15],
    wbs_adr_i[14],
    wbs_adr_i[13],
    wbs_adr_i[12],
    wbs_adr_i[11],
    wbs_adr_i[10],
    wbs_adr_i[9],
    wbs_adr_i[8],
    wbs_adr_i[7],
    wbs_adr_i[6],
    wbs_adr_i[5],
    wbs_adr_i[4],
    wbs_adr_i[3],
    wbs_adr_i[2],
    wbs_adr_i[1],
    wbs_adr_i[0]}),
    .wbs_dat_i({wbs_dat_i[31],
    wbs_dat_i[30],
    wbs_dat_i[29],
    wbs_dat_i[28],
    wbs_dat_i[27],
    wbs_dat_i[26],
    wbs_dat_i[25],
    wbs_dat_i[24],
    wbs_dat_i[23],
    wbs_dat_i[22],
    wbs_dat_i[21],
    wbs_dat_i[20],
    wbs_dat_i[19],
    wbs_dat_i[18],
    wbs_dat_i[17],
    wbs_dat_i[16],
    wbs_dat_i[15],
    wbs_dat_i[14],
    wbs_dat_i[13],
    wbs_dat_i[12],
    wbs_dat_i[11],
    wbs_dat_i[10],
    wbs_dat_i[9],
    wbs_dat_i[8],
    wbs_dat_i[7],
    wbs_dat_i[6],
    wbs_dat_i[5],
    wbs_dat_i[4],
    wbs_dat_i[3],
    wbs_dat_i[2],
    wbs_dat_i[1],
    wbs_dat_i[0]}),
    .wbs_dat_o({wbs_dat_o[31],
    wbs_dat_o[30],
    wbs_dat_o[29],
    wbs_dat_o[28],
    wbs_dat_o[27],
    wbs_dat_o[26],
    wbs_dat_o[25],
    wbs_dat_o[24],
    wbs_dat_o[23],
    wbs_dat_o[22],
    wbs_dat_o[21],
    wbs_dat_o[20],
    wbs_dat_o[19],
    wbs_dat_o[18],
    wbs_dat_o[17],
    wbs_dat_o[16],
    wbs_dat_o[15],
    wbs_dat_o[14],
    wbs_dat_o[13],
    wbs_dat_o[12],
    wbs_dat_o[11],
    wbs_dat_o[10],
    wbs_dat_o[9],
    wbs_dat_o[8],
    wbs_dat_o[7],
    wbs_dat_o[6],
    wbs_dat_o[5],
    wbs_dat_o[4],
    wbs_dat_o[3],
    wbs_dat_o[2],
    wbs_dat_o[1],
    wbs_dat_o[0]}));
endmodule
