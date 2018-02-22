puts "Info: Running script [info script]\n"

# the following script takes bsg_designs list and changes some pure-verilog
# modules with tech-dependent ones
source /home/projects/ee477/stdavids/ee477-cad/rm_dc_scripts/dc.filelist.tcl
source /home/projects/ee477/stdavids/ee477-cad/rm_dc_scripts/dc.include.tcl

set_app_var search_path "${SVERILOG_INCLUDE_PATHS} $search_path"
#if { ! [file exists ${DESIGN_NAME}_dclib] } { file mkdir ${DESIGN_NAME}_dclib }

# The first "WORK" is a reserved word for Design Compiler.
# The value for -path option is customizable.
#define_design_lib WORK -path ./${DESIGN_NAME}_dclib

puts "Info: Reading the following System Verilog files for synthesis.\n"
# Print one file per line
redirect -tee sverilog_filelist_dc.txt {puts "[join $SVERILOG_SOURCE_FILES \n]\n"}

puts "Info: Number of System Verilog files: [llength $SVERILOG_SOURCE_FILES]\n"

# this is for reading generated gate-level files that are not RTL, and have rp_group commands in them
read_verilog -netlist $NETLIST_SOURCE_FILES

set_dont_touch [get_designs bsg_rp*]

# we need to prevent tiehi and tielo signals from being turned back into 0's and 1's
set_compile_directives -constant_propagation false [get_designs bsg_rp_tsmc_*_TIEHI_b*]
set_compile_directives -constant_propagation false [get_designs bsg_rp_tsmc_*_TIELO_b*]

# Definition of "ASIC" could be removed when murn code is refactored.
set result [analyze -define {ASIC SYNTHESIS_HARDWARE NO_DUMMY} -format sverilog $SVERILOG_SOURCE_FILES]

if {$result == 0} {
    exit -1
}

elaborate ${DESIGN_NAME}

puts "*************************************************************"
puts "*********   AFTER THIS LINE IS DESIGN SPECIFIC **************"
puts "*************************************************************"


query_objects [all_rp_groups]

# let's optimize these individually; and get relative placement to track correctly
# when verilog is used to go from DC to ICC
check_design -multiple_designs

puts "Info: Completed script [info script]\n"
