# report_timing.tcl
#
# This file is used to generate timing reports desired for this
# design. In toplevels/common there are some useful functions and
# scripts to generate common timing reports that should probably
# be sourced by default.
#


# TODO: Add all path groups you would like to
#       generate reports for in this list as a
#       space separated list;
set path_groups [join "
    master_io_clk
    core_clk    
"]


# Generate a report for each path group
foreach group_name $path_groups {

  #
  # Synthesis specific timing reports
  #
  if {$synopsys_program_name == "dc_shell"} {
    report_timing -delay_type max -path_type full_clock -max_paths 30 -transition_time -nets -attributes -nosplit -group $group_name > ${DC_REPORTS_DIR}/${DESIGN_NAME}.mapped.max.timing.$group_name.rpt
  }
  
  #
  # Layout specific timing reports
  #
  if {$synopsys_program_name == "icc_shell"} {
    redirect -file $REPORTS_DIR/$ICC_CHIP_FINISH_CEL.timing.$group_name.rpt {report_timing -input_pins -capacitance -transition_time -nets -significant_digits 4 -attributes -nosplit -nworst 10 -max_paths 500 -group $group_name}
  }

}

