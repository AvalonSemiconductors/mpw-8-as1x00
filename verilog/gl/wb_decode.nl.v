// This is the unpowered netlist.
module wb_decode (ram_csb,
    ram_web,
    wb_clk_i,
    wbs_we_i,
    ram_adrb,
    wbs_adr_i);
 output ram_csb;
 output ram_web;
 input wb_clk_i;
 input wbs_we_i;
 output [8:0] ram_adrb;
 input [31:0] wbs_adr_i;

 wire net1;
 wire net2;
 wire net3;
 wire net4;
 wire net5;
 wire net6;
 wire net7;
 wire net8;
 wire net9;
 wire net10;
 wire net11;
 wire net12;
 wire net13;
 wire net14;
 wire net15;
 wire net16;
 wire net17;
 wire net18;
 wire net19;
 wire net20;
 wire net21;
 wire net22;

 sky130_fd_sc_hd__inv_2 _00_ (.A(net2),
    .Y(net21));
 sky130_fd_sc_hd__inv_2 _01_ (.A(net11),
    .Y(net22));
 sky130_fd_sc_hd__clkbuf_1 _02_ (.A(net1),
    .X(net12));
 sky130_fd_sc_hd__clkbuf_1 _03_ (.A(net3),
    .X(net13));
 sky130_fd_sc_hd__clkbuf_1 _04_ (.A(net4),
    .X(net14));
 sky130_fd_sc_hd__clkbuf_1 _05_ (.A(net5),
    .X(net15));
 sky130_fd_sc_hd__clkbuf_1 _06_ (.A(net6),
    .X(net16));
 sky130_fd_sc_hd__clkbuf_1 _07_ (.A(net7),
    .X(net17));
 sky130_fd_sc_hd__clkbuf_1 _08_ (.A(net8),
    .X(net18));
 sky130_fd_sc_hd__clkbuf_1 _09_ (.A(net9),
    .X(net19));
 sky130_fd_sc_hd__clkbuf_1 _10_ (.A(net10),
    .X(net20));
 sky130_fd_sc_hd__decap_3 PHY_0 ();
 sky130_fd_sc_hd__decap_3 PHY_1 ();
 sky130_fd_sc_hd__decap_3 PHY_2 ();
 sky130_fd_sc_hd__decap_3 PHY_3 ();
 sky130_fd_sc_hd__decap_3 PHY_4 ();
 sky130_fd_sc_hd__decap_3 PHY_5 ();
 sky130_fd_sc_hd__decap_3 PHY_6 ();
 sky130_fd_sc_hd__decap_3 PHY_7 ();
 sky130_fd_sc_hd__decap_3 PHY_8 ();
 sky130_fd_sc_hd__decap_3 PHY_9 ();
 sky130_fd_sc_hd__decap_3 PHY_10 ();
 sky130_fd_sc_hd__decap_3 PHY_11 ();
 sky130_fd_sc_hd__decap_3 PHY_12 ();
 sky130_fd_sc_hd__decap_3 PHY_13 ();
 sky130_fd_sc_hd__decap_3 PHY_14 ();
 sky130_fd_sc_hd__decap_3 PHY_15 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_16 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_17 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_18 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_19 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_20 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_21 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_22 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_23 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_24 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_25 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_26 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_27 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_28 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_29 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_30 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_31 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_32 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_33 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_34 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_35 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_36 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_37 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_38 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_39 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_40 ();
 sky130_fd_sc_hd__clkbuf_1 input1 (.A(wbs_adr_i[0]),
    .X(net1));
 sky130_fd_sc_hd__clkbuf_1 input2 (.A(wbs_adr_i[16]),
    .X(net2));
 sky130_fd_sc_hd__clkbuf_1 input3 (.A(wbs_adr_i[1]),
    .X(net3));
 sky130_fd_sc_hd__clkbuf_1 input4 (.A(wbs_adr_i[2]),
    .X(net4));
 sky130_fd_sc_hd__clkbuf_1 input5 (.A(wbs_adr_i[3]),
    .X(net5));
 sky130_fd_sc_hd__clkbuf_1 input6 (.A(wbs_adr_i[4]),
    .X(net6));
 sky130_fd_sc_hd__clkbuf_1 input7 (.A(wbs_adr_i[5]),
    .X(net7));
 sky130_fd_sc_hd__clkbuf_1 input8 (.A(wbs_adr_i[6]),
    .X(net8));
 sky130_fd_sc_hd__clkbuf_1 input9 (.A(wbs_adr_i[7]),
    .X(net9));
 sky130_fd_sc_hd__clkbuf_1 input10 (.A(wbs_adr_i[8]),
    .X(net10));
 sky130_fd_sc_hd__clkbuf_1 input11 (.A(wbs_we_i),
    .X(net11));
 sky130_fd_sc_hd__buf_2 output12 (.A(net12),
    .X(ram_adrb[0]));
 sky130_fd_sc_hd__buf_2 output13 (.A(net13),
    .X(ram_adrb[1]));
 sky130_fd_sc_hd__buf_2 output14 (.A(net14),
    .X(ram_adrb[2]));
 sky130_fd_sc_hd__buf_2 output15 (.A(net15),
    .X(ram_adrb[3]));
 sky130_fd_sc_hd__buf_2 output16 (.A(net16),
    .X(ram_adrb[4]));
 sky130_fd_sc_hd__buf_2 output17 (.A(net17),
    .X(ram_adrb[5]));
 sky130_fd_sc_hd__buf_2 output18 (.A(net18),
    .X(ram_adrb[6]));
 sky130_fd_sc_hd__buf_2 output19 (.A(net19),
    .X(ram_adrb[7]));
 sky130_fd_sc_hd__buf_2 output20 (.A(net20),
    .X(ram_adrb[8]));
 sky130_fd_sc_hd__buf_2 output21 (.A(net21),
    .X(ram_csb));
 sky130_fd_sc_hd__buf_2 output22 (.A(net22),
    .X(ram_web));
 sky130_fd_sc_hd__diode_2 ANTENNA_input1_A (.DIODE(wbs_adr_i[0]));
 sky130_fd_sc_hd__diode_2 ANTENNA_input2_A (.DIODE(wbs_adr_i[16]));
 sky130_fd_sc_hd__diode_2 ANTENNA_input3_A (.DIODE(wbs_adr_i[1]));
 sky130_fd_sc_hd__diode_2 ANTENNA_input4_A (.DIODE(wbs_adr_i[2]));
 sky130_fd_sc_hd__diode_2 ANTENNA_input5_A (.DIODE(wbs_adr_i[3]));
 sky130_fd_sc_hd__diode_2 ANTENNA_input6_A (.DIODE(wbs_adr_i[4]));
 sky130_fd_sc_hd__diode_2 ANTENNA_input7_A (.DIODE(wbs_adr_i[5]));
 sky130_fd_sc_hd__diode_2 ANTENNA_input8_A (.DIODE(wbs_adr_i[6]));
 sky130_fd_sc_hd__diode_2 ANTENNA_input9_A (.DIODE(wbs_adr_i[7]));
 sky130_fd_sc_hd__diode_2 ANTENNA_input10_A (.DIODE(wbs_adr_i[8]));
 sky130_fd_sc_hd__diode_2 ANTENNA_input11_A (.DIODE(wbs_we_i));
 sky130_fd_sc_hd__fill_2 FILLER_0_3 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_9 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_19 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_27 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_29 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_35 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_43 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_49 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_55 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_57 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_64 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_72 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_79 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_83 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_85 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_89 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_94 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_102 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_109 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_113 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_119 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_124 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_132 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_138 ();
 sky130_fd_sc_hd__decap_4 FILLER_0_141 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_145 ();
 sky130_ef_sc_hd__decap_12 FILLER_1_3 ();
 sky130_ef_sc_hd__decap_12 FILLER_1_15 ();
 sky130_ef_sc_hd__decap_12 FILLER_1_27 ();
 sky130_ef_sc_hd__decap_12 FILLER_1_39 ();
 sky130_fd_sc_hd__decap_4 FILLER_1_51 ();
 sky130_fd_sc_hd__fill_1 FILLER_1_55 ();
 sky130_ef_sc_hd__decap_12 FILLER_1_57 ();
 sky130_ef_sc_hd__decap_12 FILLER_1_69 ();
 sky130_ef_sc_hd__decap_12 FILLER_1_81 ();
 sky130_ef_sc_hd__decap_12 FILLER_1_93 ();
 sky130_fd_sc_hd__decap_6 FILLER_1_105 ();
 sky130_fd_sc_hd__fill_1 FILLER_1_111 ();
 sky130_ef_sc_hd__decap_12 FILLER_1_113 ();
 sky130_ef_sc_hd__decap_12 FILLER_1_125 ();
 sky130_fd_sc_hd__decap_3 FILLER_1_137 ();
 sky130_fd_sc_hd__fill_2 FILLER_1_144 ();
 sky130_fd_sc_hd__fill_2 FILLER_2_3 ();
 sky130_ef_sc_hd__decap_12 FILLER_2_7 ();
 sky130_fd_sc_hd__decap_8 FILLER_2_19 ();
 sky130_fd_sc_hd__fill_1 FILLER_2_27 ();
 sky130_ef_sc_hd__decap_12 FILLER_2_29 ();
 sky130_ef_sc_hd__decap_12 FILLER_2_41 ();
 sky130_ef_sc_hd__decap_12 FILLER_2_53 ();
 sky130_fd_sc_hd__decap_8 FILLER_2_65 ();
 sky130_fd_sc_hd__fill_1 FILLER_2_73 ();
 sky130_fd_sc_hd__decap_6 FILLER_2_77 ();
 sky130_fd_sc_hd__fill_1 FILLER_2_83 ();
 sky130_ef_sc_hd__decap_12 FILLER_2_85 ();
 sky130_ef_sc_hd__decap_12 FILLER_2_97 ();
 sky130_ef_sc_hd__decap_12 FILLER_2_109 ();
 sky130_ef_sc_hd__decap_12 FILLER_2_121 ();
 sky130_fd_sc_hd__decap_6 FILLER_2_133 ();
 sky130_fd_sc_hd__fill_1 FILLER_2_139 ();
 sky130_fd_sc_hd__decap_4 FILLER_2_141 ();
 sky130_fd_sc_hd__fill_1 FILLER_2_145 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_3 ();
 sky130_fd_sc_hd__decap_8 FILLER_3_8 ();
 sky130_fd_sc_hd__fill_1 FILLER_3_16 ();
 sky130_ef_sc_hd__decap_12 FILLER_3_20 ();
 sky130_ef_sc_hd__decap_12 FILLER_3_35 ();
 sky130_fd_sc_hd__decap_8 FILLER_3_47 ();
 sky130_fd_sc_hd__fill_1 FILLER_3_55 ();
 sky130_fd_sc_hd__decap_8 FILLER_3_57 ();
 sky130_fd_sc_hd__fill_2 FILLER_3_65 ();
 sky130_fd_sc_hd__decap_4 FILLER_3_70 ();
 sky130_fd_sc_hd__decap_4 FILLER_3_77 ();
 sky130_ef_sc_hd__decap_12 FILLER_3_84 ();
 sky130_ef_sc_hd__decap_12 FILLER_3_96 ();
 sky130_fd_sc_hd__decap_4 FILLER_3_108 ();
 sky130_ef_sc_hd__decap_12 FILLER_3_113 ();
 sky130_ef_sc_hd__decap_12 FILLER_3_125 ();
 sky130_fd_sc_hd__decap_8 FILLER_3_137 ();
 sky130_fd_sc_hd__fill_1 FILLER_3_145 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_3 ();
 sky130_fd_sc_hd__decap_4 FILLER_4_8 ();
 sky130_fd_sc_hd__decap_6 FILLER_4_15 ();
 sky130_fd_sc_hd__decap_4 FILLER_4_23 ();
 sky130_fd_sc_hd__fill_1 FILLER_4_27 ();
 sky130_ef_sc_hd__decap_12 FILLER_4_29 ();
 sky130_fd_sc_hd__decap_6 FILLER_4_41 ();
 sky130_fd_sc_hd__fill_1 FILLER_4_47 ();
 sky130_ef_sc_hd__decap_12 FILLER_4_51 ();
 sky130_fd_sc_hd__decap_4 FILLER_4_63 ();
 sky130_fd_sc_hd__decap_4 FILLER_4_70 ();
 sky130_fd_sc_hd__decap_6 FILLER_4_77 ();
 sky130_fd_sc_hd__fill_1 FILLER_4_83 ();
 sky130_ef_sc_hd__decap_12 FILLER_4_85 ();
 sky130_ef_sc_hd__decap_12 FILLER_4_97 ();
 sky130_ef_sc_hd__decap_12 FILLER_4_109 ();
 sky130_ef_sc_hd__decap_12 FILLER_4_121 ();
 sky130_fd_sc_hd__decap_6 FILLER_4_133 ();
 sky130_fd_sc_hd__fill_1 FILLER_4_139 ();
 sky130_fd_sc_hd__decap_4 FILLER_4_141 ();
 sky130_fd_sc_hd__fill_1 FILLER_4_145 ();
 sky130_fd_sc_hd__fill_2 FILLER_5_3 ();
 sky130_fd_sc_hd__decap_4 FILLER_5_8 ();
 sky130_fd_sc_hd__decap_4 FILLER_5_14 ();
 sky130_fd_sc_hd__fill_1 FILLER_5_18 ();
 sky130_fd_sc_hd__decap_4 FILLER_5_21 ();
 sky130_fd_sc_hd__fill_1 FILLER_5_25 ();
 sky130_fd_sc_hd__decap_4 FILLER_5_28 ();
 sky130_ef_sc_hd__decap_12 FILLER_5_34 ();
 sky130_fd_sc_hd__decap_8 FILLER_5_46 ();
 sky130_fd_sc_hd__fill_2 FILLER_5_54 ();
 sky130_fd_sc_hd__decap_8 FILLER_5_57 ();
 sky130_fd_sc_hd__fill_1 FILLER_5_65 ();
 sky130_ef_sc_hd__decap_12 FILLER_5_69 ();
 sky130_ef_sc_hd__decap_12 FILLER_5_81 ();
 sky130_ef_sc_hd__decap_12 FILLER_5_93 ();
 sky130_fd_sc_hd__decap_6 FILLER_5_105 ();
 sky130_fd_sc_hd__fill_1 FILLER_5_111 ();
 sky130_ef_sc_hd__decap_12 FILLER_5_113 ();
 sky130_ef_sc_hd__decap_12 FILLER_5_125 ();
 sky130_fd_sc_hd__decap_8 FILLER_5_137 ();
 sky130_fd_sc_hd__fill_1 FILLER_5_145 ();
 sky130_fd_sc_hd__decap_4 FILLER_6_3 ();
 sky130_fd_sc_hd__fill_1 FILLER_6_7 ();
 sky130_fd_sc_hd__decap_4 FILLER_6_11 ();
 sky130_fd_sc_hd__decap_4 FILLER_6_18 ();
 sky130_fd_sc_hd__fill_1 FILLER_6_22 ();
 sky130_fd_sc_hd__fill_2 FILLER_6_26 ();
 sky130_fd_sc_hd__decap_4 FILLER_6_29 ();
 sky130_fd_sc_hd__decap_4 FILLER_6_36 ();
 sky130_ef_sc_hd__decap_12 FILLER_6_42 ();
 sky130_ef_sc_hd__decap_12 FILLER_6_54 ();
 sky130_ef_sc_hd__decap_12 FILLER_6_66 ();
 sky130_fd_sc_hd__decap_6 FILLER_6_78 ();
 sky130_ef_sc_hd__decap_12 FILLER_6_85 ();
 sky130_ef_sc_hd__decap_12 FILLER_6_97 ();
 sky130_ef_sc_hd__decap_12 FILLER_6_109 ();
 sky130_ef_sc_hd__decap_12 FILLER_6_121 ();
 sky130_fd_sc_hd__decap_6 FILLER_6_133 ();
 sky130_fd_sc_hd__fill_1 FILLER_6_139 ();
 sky130_fd_sc_hd__decap_4 FILLER_6_141 ();
 sky130_fd_sc_hd__fill_1 FILLER_6_145 ();
 sky130_fd_sc_hd__decap_6 FILLER_7_3 ();
 sky130_fd_sc_hd__decap_4 FILLER_7_12 ();
 sky130_fd_sc_hd__decap_4 FILLER_7_19 ();
 sky130_fd_sc_hd__fill_2 FILLER_7_26 ();
 sky130_fd_sc_hd__decap_6 FILLER_7_29 ();
 sky130_fd_sc_hd__fill_1 FILLER_7_35 ();
 sky130_fd_sc_hd__decap_4 FILLER_7_39 ();
 sky130_fd_sc_hd__decap_4 FILLER_7_46 ();
 sky130_fd_sc_hd__decap_4 FILLER_7_52 ();
 sky130_ef_sc_hd__decap_12 FILLER_7_57 ();
 sky130_ef_sc_hd__decap_12 FILLER_7_69 ();
 sky130_fd_sc_hd__decap_3 FILLER_7_81 ();
 sky130_fd_sc_hd__fill_2 FILLER_7_85 ();
 sky130_fd_sc_hd__decap_4 FILLER_7_90 ();
 sky130_ef_sc_hd__decap_12 FILLER_7_96 ();
 sky130_fd_sc_hd__decap_4 FILLER_7_108 ();
 sky130_ef_sc_hd__decap_12 FILLER_7_113 ();
 sky130_ef_sc_hd__decap_12 FILLER_7_125 ();
 sky130_fd_sc_hd__decap_3 FILLER_7_137 ();
 sky130_fd_sc_hd__decap_4 FILLER_7_141 ();
 sky130_fd_sc_hd__fill_1 FILLER_7_145 ();
endmodule

