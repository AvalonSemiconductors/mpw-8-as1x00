###############################################################################
# Created by write_sdc
# Wed Jan 18 17:09:08 2023
###############################################################################
current_design tms1x00_ram
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name clk -period 10.0000 [get_ports {clk}]
set_clock_transition 0.1500 [get_clocks {clk}]
set_clock_uncertainty 0.2500 clk
set_propagated_clock [get_clocks {clk}]
set_input_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {ram_addr[0]}]
set_input_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {ram_addr[1]}]
set_input_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {ram_addr[2]}]
set_input_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {ram_addr[3]}]
set_input_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {ram_addr[4]}]
set_input_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {ram_addr[5]}]
set_input_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {ram_addr[6]}]
set_input_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {w_val[0]}]
set_input_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {w_val[1]}]
set_input_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {w_val[2]}]
set_input_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {w_val[3]}]
set_input_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {wen}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {r_val[0]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {r_val[1]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {r_val[2]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {r_val[3]}]
###############################################################################
# Environment
###############################################################################
set_load -pin_load 0.0334 [get_ports {r_val[3]}]
set_load -pin_load 0.0334 [get_ports {r_val[2]}]
set_load -pin_load 0.0334 [get_ports {r_val[1]}]
set_load -pin_load 0.0334 [get_ports {r_val[0]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {clk}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wen}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {ram_addr[6]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {ram_addr[5]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {ram_addr[4]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {ram_addr[3]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {ram_addr[2]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {ram_addr[1]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {ram_addr[0]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {w_val[3]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {w_val[2]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {w_val[1]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {w_val[0]}]
set_timing_derate -early 0.9500
set_timing_derate -late 1.0500
###############################################################################
# Design Rules
###############################################################################
set_max_fanout 10.0000 [current_design]
