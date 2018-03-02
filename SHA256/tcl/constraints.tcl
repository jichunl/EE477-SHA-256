# constraints.tcl
#
# This file is where design timing constraints are defined for dc and
# icc. There are multiple files in toplevels/common that define helper
# functions for setting up complex timing constraints and block constraints
# for components such ass bsg_comm_link, bsg_tag and bsg_clk_gen.
#
source -echo -verbose $::env(BSG_DESIGNS_DIR)/toplevels/common/constraints/bsg_chip_timing_constraint.tcl

set CORE_CLOCK_PERIOD      20
set IO_MASTER_CLOCK_PERIOD 15

bsg_chip_timing_constraint                                 \
    -package ucsd_bsg_332                                  \
    -reset_port [get_ports p_reset_i]                      \
    -core_clk_port [get_ports p_misc_L_4_i]                \
    -core_clk_name core_clk                                \
    -core_clk_period ${CORE_CLOCK_PERIOD}                  \
    -master_io_clk_port [get_ports p_PLL_CLK_i]            \
    -master_io_clk_name master_io_clk                      \
    -master_io_clk_period ${IO_MASTER_CLOCK_PERIOD}        \
    -create_core_clk 1                                     \
    -create_master_clk 1                                   \
    -input_cell_rise_fall_difference    [expr 1.37 - 1.15] \
    -output_cell_rise_fall_difference_A 0.8                \
    -output_cell_rise_fall_difference_B 0.67               \
    -output_cell_rise_fall_difference_C 0.17               \
    -output_cell_rise_fall_difference_D 0.34 

create_clock -period 20 -name "gcd_clk" [get_pins guts/n[1].clnt.clnt/genblk1.node/clk_i]
create_clock -period 20 -name "cpu_clk" [get_pins guts/n[2].clnt.clnt/genblk1.node/clk_i]
