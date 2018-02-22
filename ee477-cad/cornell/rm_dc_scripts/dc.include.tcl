source $::env(BSG_DESIGNS_TARGET_DIR)/tcl/include.tcl

# include replacement

# set generic and tsmc iopads folders for replacement
set generic_iopads_dir $::env(BSG_PACKAGING_DIR)/common/foundry/portable/verilog
set tsmc_iopads_dir $::env(BSG_PACKAGING_DIR)/common/foundry/$::env(BSG_PACKAGING_FOUNDRY)/verilog

# replace generic iopad folder with tsmc iopad one
set idx [lsearch $SVERILOG_INCLUDE_PATHS $generic_iopads_dir]
set SVERILOG_INCLUDE_PATHS [lreplace $SVERILOG_INCLUDE_PATHS $idx $idx $tsmc_iopads_dir]
