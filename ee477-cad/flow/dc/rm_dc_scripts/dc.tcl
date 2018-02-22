source -echo -verbose ./rm_setup/dc_setup.tcl

#################################################################################
# Design Compiler Reference Methodology Script for Top-Down Flow
# Script: dc.tcl
# Version: G-2012.06-SP4 (January 11, 2013)
# Copyright (C) 2007-2013 Synopsys, Inc. All rights reserved.
#################################################################################

#################################################################################
# Additional Variables
#
# Add any additional variables needed for your flow here.
#################################################################################

# No additional flow variables are being recommended

#################################################################################
# Setup for Formality Verification
#################################################################################

# In the event of an inconclusive (or hard) verification, we recommend using
# the set_verification_priority commands provided from the analyze_points command
# in Formality. The set_verification_priority commands target specific
# operators to reduce verification complexity while minimizing QoR impact.
# The set_verification_priority commands should be applied after the design
# is read and elaborated.

# For designs that don't have tight QoR constraints and don't have register retiming,
# you can use the following variable to enable the highest productivity single pass flow.
# This flow modifies the optimizations to make verification easier.
# This variable setting should be applied prior to reading in the RTL for the design.

# set_app_var simplified_verification_mode true

# For more information about facilitating formal verification in the flow, refer
# to the following SolvNet article:
# "Resolving Inconclusive and Hard Verifications in Design Compiler"
# https://solvnet.synopsys.com/retrieve/033140.html

# Define the verification setup file for Formality
set_svf ${DC_RESULTS_DIR}/${DCRM_SVF_OUTPUT_FILE}

#################################################################################
# Setup SAIF Name Mapping Database
#
# Include an RTL SAIF for better power optimization and analysis.
#
# saif_map should be issued prior to RTL elaboration to create a name mapping
# database for better annotation.
################################################################################

saif_map -start

#################################################################################
# Read in the RTL Design
#
# Read in the RTL source files or read in the elaborated design (.ddc).
#################################################################################

puts "RM-Info: Sourcing script file [which ${DCRM_RTL_READ_SCRIPT}]\n"

# Use the following OS-Shell-level environment variables to enable queuing on licenses.
# SNPSLMD_QUEUE
# SCL_QUEUE_ON_MAX
# SNPS_MAX_WAITTIME
# SNPS_MAX_QUEUETIME
#
# If the above queuing variables are not set, use the DC application-level
# variable synlib_wait_for_design_license as follows.
#
# set_app_var synlib_wait_for_design_license [list DesignWare HDL-Compiler DC-Expert \
#                                                  DC-Ultra-Opt DC-Ultra-Features \
#                                                  DC-SDF-Interface Power-Optimization]

source -echo -verbose ${DCRM_RTL_READ_SCRIPT}

# OR

# You can read an elaborated design from the same release.
# Using an elaborated design from an older release will not give the best results.

# read_ddc ${DCRM_ELABORATED_DESIGN_DDC_OUTPUT_FILE}

current_design ${DESIGN_NAME}

# MBT: exit out if link fails
set link_result [link]
if {$link_result == 0} {
    exit -1
}

set_dont_touch [all_inputs] true
set_dont_touch [all_outputs] true

write_file -hierarchy -format ddc -output ${DC_RESULTS_DIR}/${DCRM_ELABORATED_DESIGN_DDC_OUTPUT_FILE}

# mbt see elaborated design
write_file -hierarchy -format verilog -output ${DC_RESULTS_DIR}/${DCRM_ELABORATED_DESIGN_DDC_OUTPUT_FILE}.v

#################################################################################
# Apply Logical Design Constraints
#################################################################################

# You can use either SDC file ${DCRM_SDC_INPUT_FILE} or Tcl file
# ${DCRM_CONSTRAINTS_INPUT_FILE} to constrain your design.
if {[file exists [which ${DCRM_SDC_INPUT_FILE}]]} {
  puts "RM-Info: Reading SDC file [which ${DCRM_SDC_INPUT_FILE}]\n"
  read_sdc ${DCRM_SDC_INPUT_FILE}
}
if {[file exists [which ${DCRM_CONSTRAINTS_INPUT_FILE}]]} {
  puts "RM-Info: Sourcing script file [which ${DCRM_CONSTRAINTS_INPUT_FILE}]\n"
  source -echo -verbose ${DCRM_CONSTRAINTS_INPUT_FILE}
}

# You can enable analysis and optimization for multiple clocks per register.
# To use this, you must constrain to remove false interactions between mutually exclusive
# clocks. This is needed to prevent unnecessary analysis that can result in
# a significant runtime increase with this feature enabled.
#
# set_clock_groups -physically_exclusive | -logically_exclusive | -asynchronous \
#                  -group {CLKA, CLKB} -group {CLKC, CLKD}
#
# set_app_var timing_enable_multiple_clocks_per_reg true

# The check_timing command checks for constraint problems such as undefined
# clocking, undefined input arrival times, and undefined output constraints.
# These constraint problems could cause you to overlook timing violations. For
# this reason, the check_timing command is recommended whenever you apply new
# constraints such as clock definitions, I/O delays, or timing exceptions.

redirect -tee ${DC_REPORTS_DIR}/${DESIGN_NAME}.check_timing.rpt {check_timing}

#################################################################################
# Apply The Operating Conditions
#################################################################################

# Set operating condition on top level

# set_operating_conditions -max <max_opcond> -min <min_opcond>

#################################################################################
# Create Default Path Groups
#
# Separating these paths can help improve optimization.
#
# Remove these path group settings if user path groups have already been defined.
#
# During compile each timing path is placed into a path group associated with
# that path's capturing clock. DC then optimizes each path group in turn,
# starting with the critical path in each group.
#################################################################################

# set ports_clock_root [filter_collection [get_attribute [get_clocks] sources] object_class==port]
# group_path -name REGOUT -to [all_outputs]
# group_path -name REGIN -from [remove_from_collection [all_inputs] ${ports_clock_root}]
# group_path -name FEEDTHROUGH -from [remove_from_collection [all_inputs] ${ports_clock_root}] -to [all_outputs]

#################################################################################
# Power Optimization Section
#################################################################################

#############################################################################
# Clock Gating Setup
#############################################################################

# Default clock_gating_style suits most designs. Change only if necessary.
# set_clock_gating_style -positive_edge_logic {integrated} -negative_edge_logic {integrated} -control_point before ...

# Clock gate insertion is now performed during compile_ultra -gate_clock
# so insert_clock_gating is no longer recommended at this step.

# The following setting can be used to enable global clock gating.
# With global clock gating, common enables are extracted across hierarchies
# which results in fewer redundant clock gates.

# set compile_clock_gating_through_hierarchy true

# For better timing optimization of enable logic, clock latency for
# clock gating cells can be optionally specified.

# set_clock_gate_latency -clock <clock_name> -stage <stage_num> \
#                        -fanout_latency {fanout_range1 latency_val1 fanout_range2 latency_val2 ...}

#############################################################################
# Apply Power Optimization Constraints
#############################################################################

# Include a SAIF file, if possible, for power optimization. If a SAIF file
# is not provided, the default toggle rate of 0.1 will be used for propagating
# switching activity.

# read_saif -auto_map_names -input ${DESIGN_NAME}.saif -instance < DESIGN_INSTANCE > -verbose

# This optimization may cause some issues on gate-level simulation. Use with caution.
# set_leakage_optimization true

# set_dynamic_optimization true

if {[shell_is_in_topographical_mode]} {
  # Use the following command to enable power prediction using clock tree estimation.

  # set_power_prediction true -ct_references <LIB CELL LIST>
}

if {[shell_is_in_topographical_mode]} {

  ##################################################################################
  # Apply Physical Design Constraints
  #
  # Optional: Floorplan information can be read in here if available.
  # This is highly recommended for irregular floorplans.
  #
  # Floorplan constraints can be provided from one of the following sources:
  # * extract_physical_constraints with a DEF file
  # * read_floorplan with a floorplan file (written by write_floorplan)
  # * User generated Tcl physical constraints
  #
  ##################################################################################

  # Specify ignored layers for routing to improve correlation
  # Use the same ignored layers that will be used during place and route

  if { ${MIN_ROUTING_LAYER} != ""} {
    set_ignored_layers -min_routing_layer ${MIN_ROUTING_LAYER}
  }
  if { ${MAX_ROUTING_LAYER} != ""} {
    set_ignored_layers -max_routing_layer ${MAX_ROUTING_LAYER}
  }

  report_ignored_layers

  # If the macro names change after mapping and writing out the design due to
  # ungrouping or Verilog change_names renaming, it may be necessary to translate
  # the names to correspond to the cell names that exist before compile.

  # During DEF constraint extraction, extract_physical_constraints automatically
  # matches DEF names back to precompile names in memory using standard matching rules.
  # read_floorplan will also automatically perform this name matching.

  # Modify fuzzy_query_options if other characters are used for hierarchy separators
  # or bus names.

  # set_fuzzy_query_options -hierarchical_separators {/ _ .} \
  #                         -bus_name_notations {[] __ ()} \
  #                         -class {cell pin port net} \
  #                         -show

  ## For DEF floorplan input

  # The DEF file for Design Compiler Topographical can be written from IC Compiler using the following
  # recommended options:
  # icc_shell> write_def -version 5.7 -rows_tracks_gcells -fixed -pins -blockages -specialnets \
  #                      -vias -regions_groups -verbose -output ${DCRM_DCT_DEF_INPUT_FILE}

  if {[file exists [which ${DCRM_DCT_DEF_INPUT_FILE}]]} {
    # If you have physical only cells as a part of your floorplan DEF file, you can use
    # the -allow_physical_cells option with extract_physical_constraints to include
    # the physical only cells as a part of the floorplan in Design Compiler to improve correlation.
    #
    # Note: With -allow_physical_cells, new logical cells in the DEF file
    #       that have a fixed location will also be added to the design in memory.
    #       See the extract_physical_constraints manpage for more information about
    #       identifying the cells added to the design when using -allow_physical_cells.

    # extract_physical_constraints -allow_physical_cells ${DCRM_DCT_DEF_INPUT_FILE}

    puts "RM-Info: Reading in DEF file [which ${DCRM_DCT_DEF_INPUT_FILE}]\n"
    extract_physical_constraints ${DCRM_DCT_DEF_INPUT_FILE}
  }

  # OR

  ## For floorplan file input

  # The floorplan file for Design Compiler Topographical can be written from IC Compiler using the following
  # recommended options:
  # Note: IC Compiler requires the use of -placement {terminal} with -create_terminal beginning in the
  #       D-2010.03-SP1 release.
  # icc_shell> write_floorplan -placement {io terminal hard_macro soft_macro} -create_terminal \
  #                            -row -create_bound -preroute -track ${DCRM_DCT_FLOORPLAN_INPUT_FILE}

  # Read in the secondary floorplan file, previously written by write_floorplan in Design Compiler,
  # to restore physical-only objects back to the design, before reading the main floorplan file.

  if {[file exists [which ${DCRM_DCT_FLOORPLAN_INPUT_FILE}.objects]]} {
    puts "RM-Info: Reading in secondary floorplan file [which ${DCRM_DCT_FLOORPLAN_INPUT_FILE}.objects]\n"
    read_floorplan ${DCRM_DCT_FLOORPLAN_INPUT_FILE}.objects
  }

  if {[file exists [which ${DCRM_DCT_FLOORPLAN_INPUT_FILE}]]} {
    puts "RM-Info: Reading in floorplan file [which ${DCRM_DCT_FLOORPLAN_INPUT_FILE}]\n"
    read_floorplan ${DCRM_DCT_FLOORPLAN_INPUT_FILE}
  }

  # OR

  ## For Tcl file input

  # For Tcl constraints, the name matching feature must be explicitly enabled
  # and will also use the set_fuzzy_query_options setttings. This should
  # be turned off after the constraint read in order to minimize runtime.

  if {[file exists [which ${DCRM_DCT_PHYSICAL_CONSTRAINTS_INPUT_FILE}]]} {
    set_app_var fuzzy_matching_enabled true
    puts "RM-Info: Sourcing script file [which ${DCRM_DCT_PHYSICAL_CONSTRAINTS_INPUT_FILE}]\n"
    source -echo -verbose ${DCRM_DCT_PHYSICAL_CONSTRAINTS_INPUT_FILE}
    set_app_var fuzzy_matching_enabled false
  }


  # Use write_floorplan to save the applied floorplan.

  # Note: A secondary floorplan file ${DCRM_DCT_FLOORPLAN_OUTPUT_FILE}.objects
  #       might also be written to capture physical-only objects in the design.
  #       This file should be read in before reading the main floorplan file.

  write_floorplan -all ${DC_RESULTS_DIR}/${DCRM_DCT_FLOORPLAN_OUTPUT_FILE}

  # Verify that all the desired physical constraints have been applied
  # Add the -pre_route option to include pre-routes in the report
  report_physical_constraints > ${DC_REPORTS_DIR}/${DCRM_DCT_PHYSICAL_CONSTRAINTS_REPORT}
}

#################################################################################
# Apply Additional Optimization Constraints
#################################################################################

# Replace special characters with non-special ones before writing out the synthesized netlist.
# For example \bus[5] -> bus_5_
set_app_var verilogout_no_tri true

# Prevent assignment statements in the Verilog netlist.
set_fix_multiple_port_nets -all -buffer_constants

# Design Compiler Flattening Options
if {[info exists DC_FLATTEN_EFFORT]} {
  set dc_flatten_effort $DC_FLATTEN_EFFORT
  if {"$dc_flatten_effort" == ""} {
    set dc_flatten_effort 0
  }
} else {
  set dc_flatten_effort 0
}

# Setup Design Compiler flattening effort
puts "Info: Design Compiler flattening effort (DC_FLATTEN_EFFORT) = $dc_flatten_effort"

set compile_ultra_options ""
if {$dc_flatten_effort == 0} {
  puts "Info: All design hierarchies are preserved unless otherwise specified."
  set_app_var compile_ultra_ungroup_dw false
  puts "Info: Design Compiler compile_ultra boundary optimization is disabled."
  set compile_ultra_options "$compile_ultra_options -no_autoungroup -no_boundary_optimization"

} elseif {$dc_flatten_effort == 1} {
  puts "Info: Unconditionally ungroup the DesignWare cells."
  set_app_var compile_ultra_ungroup_dw true
  puts "Info: Design Compiler compile_ultra automatic ungrouping is disabled."
  puts "Info: Design Compiler compile_ultra boundary optimization is disabled."
  set compile_ultra_options "$compile_ultra_options -no_autoungroup -no_boundary_optimization"

} elseif {$dc_flatten_effort == 2} {
  puts "Info: Unconditionally ungroup the DesignWare cells."
  set_app_var compile_ultra_ungroup_dw true
  puts "Info: Design Compiler compile_ultra automatic ungrouping is enabled."
  puts "Info: Design Compiler compile_ultra boundary optimization is enabled."
  set compile_ultra_options "$compile_ultra_options"

} elseif {$dc_flatten_effort == 3} {
  set ungroup_start_level 2
  ungroup -start_level $ungroup_start_level -all -flatten
  puts "Info: All hierarchical cells starting from level $ungroup_start_level are flattened."
  puts "Info: Unconditionally ungroup the DesignWare cells."
  puts "Info: Design Compiler compile_ultra automatic ungrouping is enabled."
  puts "Info: Design Compiler compile_ultra boundary optimization is enabled."
  set_app_var compile_ultra_ungroup_dw true
  set compile_ultra_options "$compile_ultra_options"

} else {
  puts "Error: Unrecognizable DC_FLATTEN_EFFORT value: $dc_flatten_effort"

}

#################################################################################
# Save the compile environment snapshot for the Consistency Checker utility.
#
# This utility checks for inconsistent settings between Design Compiler and
# IC Compiler which can contribute to correlation mismatches.
#
# Download this utility from SolvNet. See the following SolvNet article for
# complete details:
#
# https://solvnet.synopsys.com/retrieve/026366.html
#
# The article is titled: "Using the Consistency Checker to Automatically Compare
# Environment Settings Between Design Compiler and IC Compiler"
#################################################################################

# Uncomment the following to snapshot the environment for the Consistency Checker

# write_environment -consistency -output ${DC_REPORTS_DIR}/${DCRM_CONSISTENCY_CHECK_ENV_FILE}

#################################################################################
# Check for Design Errors
#################################################################################

check_design -summary
check_design > ${DC_REPORTS_DIR}/${DCRM_CHECK_DESIGN_REPORT}
check_design -html ${DC_REPORTS_DIR}/${DESIGN_NAME}.check_design.html

#################################################################################
# Compile the Design
#
# Recommended Options:
#
#     -scan
#     -gate_clock (-self_gating)
#     -retime
#     -timing_high_effort_script
#     -spg
#
# Use compile_ultra as your starting point. For test-ready compile, include
# the -scan option with the first compile and any subsequent compiles.
#
# Use -gate_clock to insert clock-gating logic during optimization. This
# is now the recommended methodology for clock gating.
#
# Note: You can use -self_gating option in addition to -gate_clock for
#       potentially saving additional dynamic power, in topographical mode
#       only. Registers that are not clock gated will be considered for XOR
#       self gating.
#       XOR self gating should be performed along with clock gating, using
#       -gate_clock and -self_gating options. XOR self gates will be inserted
#       only if there is potential power saving without degrading the timing.
#       An accurate switching activity annotation either by reading in a saif
#       file or through set_switching_activity command is recommended.
#
# Use -retime to enable adaptive retiming optimization for further timing benefit.
#
# The -timing_high_effort_script option can be used to try and improve the
# optimization results at the tradeoff of some additional runtime.
#
# Use the -spg option to enable Design Compiler Graphical physical guidance flow.
# The physical guidance flow improves QoR, area and timing correlation, and congestion.
# It also improves place_opt runtime in IC Compiler.
# You can selectively enable or disable the congestion optimization on parts of the design
# by using the set_congestion_optimization command.
# This option requires a license for Design Compiler Graphical.
#
#################################################################################

if {[shell_is_in_topographical_mode]} {
# Use the "-check_only" option of "compile_ultra" to verify that your
# libraries and design are complete and that optimization will not fail
# in topographical mode. Use the same options as will be used in compile_ultra.

# compile_ultra -check_only
}

puts "Info: Running compile_ultra $compile_ultra_options"
eval "compile_ultra $compile_ultra_options"

#################################################################################
# Write Out Final Design and Reports
#
#        .ddc:   Recommended binary format used for subsequent Design Compiler sessions
#    Milkyway:   Recommended binary format for IC Compiler
#        .v  :   Verilog netlist for ASCII flow (Formality, PrimeTime, VCS)
#       .spef:   Topographical mode parasitics for PrimeTime
#        .sdf:   SDF backannotated topographical mode timing for PrimeTime
#        .sdc:   SDC constraints for ASCII flow
#
#################################################################################

change_names -rules verilog -hierarchy -verbose > ${DC_RESULTS_DIR}/${DESIGN_NAME}.change_names.rpt

#################################################################################
# Write out Design
#################################################################################

# Write and close SVF file and make it available for immediate use
set_svf -off
uniquify -force -dont_skip_empty_designs

write_file -format ddc -hierarchy -output ${DC_RESULTS_DIR}/${DCRM_FINAL_DDC_OUTPUT_FILE}

write_file -format verilog -hierarchy -output ${DC_RESULTS_DIR}/${DCRM_FINAL_VERILOG_OUTPUT_FILE}

#################################################################################
# Write out Design Data
#################################################################################

if {[shell_is_in_topographical_mode]} {
  puts "MBT: we are in topographical mode"
  # fixme: is there a better place for this?
  puts "MBT: we are in topographical mode2"
  #this command silently crashes and aborts this whole if clause
  #check_rp_groups -all -verbose
  puts "MBT: ran check_rp_groups"
  query_objects [all_rp_groups]
  puts "MBT: ran query_objects"
  write_rp_groups -all -output ${DC_RESULTS_DIR}/bsg_rp_groups.tcl

  # Note: A secondary floorplan file ${DCRM_DCT_FINAL_FLOORPLAN_OUTPUT_FILE}.objects
  #       might also be written to capture physical-only objects in the design.
  #       This file should be read in before reading the main floorplan file.

  write_floorplan -all ${DC_RESULTS_DIR}/${DCRM_DCT_FINAL_FLOORPLAN_OUTPUT_FILE}

  # Write parasitics data from Design Compiler Topographical placement for static timing analysis
  write_parasitics -output ${DC_RESULTS_DIR}/${DCRM_DCT_FINAL_SPEF_OUTPUT_FILE}

  # Write SDF backannotation data from Design Compiler Topographical placement for static timing analysis
  write_sdf ${DC_RESULTS_DIR}/${DCRM_DCT_FINAL_SDF_OUTPUT_FILE}

  # Do not write out net RC info into SDC
  set_app_var write_sdc_output_lumped_net_capacitance false
  set_app_var write_sdc_output_net_resistance false
}

write_sdc -nosplit ${DC_RESULTS_DIR}/${DCRM_FINAL_SDC_OUTPUT_FILE}

# If SAIF is used, write out SAIF name mapping file for PrimeTime-PX
# saif_map -type ptpx -write_map ${DC_RESULTS_DIR}/${DESIGN_NAME}.mapped.SAIF.namemap

#################################################################################
# Generate Final Reports
#################################################################################

redirect -tee ${DC_REPORTS_DIR}/${DESIGN_NAME}.units.rpt {report_units}

report_qor > ${DC_REPORTS_DIR}/${DCRM_FINAL_QOR_REPORT}

# The report_clock_timing command reports the clock latency, transition time,
# and skew characteristics at specified clock pins of sequential elements in
# the network. You specify the type of report you want, the scope of the design
# to analyze, and any desired filtering or ordering options for the report. The
# tool gathers the requested clock information and reports it in the specified
# order. The report is useful for debugging latency and skew problems in the
# clock network.
#
report_clock_timing -type summary > ${DC_REPORTS_DIR}/${DESIGN_NAME}.clock_timing.rpt

# Endpoint path delay
report_timing -path end -transition_time -nets -max_paths 30 -attributes -nosplit > ${DC_REPORTS_DIR}/${DCRM_FINAL_TIMING_REPORT}
# Path timing check type (max for a setup check)
report_timing -delay_type max -path_type full_clock -max_paths 30 -transition_time -nets -attributes -nosplit > ${DC_REPORTS_DIR}/${DCRM_FINAL_MAX_TIMING_REPORT}
# Path timing check type (min for a hold check)
report_timing -delay_type min -path_type full_clock -transition_time -nets -attributes -nosplit > ${DC_REPORTS_DIR}/${DCRM_FINAL_MIN_TIMING_REPORT}

report_clock_gating -structure -nosplit -verbose > ${DC_REPORTS_DIR}/${DESIGN_NAME}.clock_gating.rpt

report_path_group -expanded -nosplit > ${DC_REPORTS_DIR}/${DESIGN_NAME}.path_group.rpt

if {[file exists [which ${DESIGN_SPECIFIC_REPORT_TIMING}]]} {
  source -echo -verbose ${DESIGN_SPECIFIC_REPORT_TIMING}
}

if {[shell_is_in_topographical_mode]} {
  report_area -physical -nosplit > ${DC_REPORTS_DIR}/${DCRM_FINAL_AREA_REPORT}
} else {
  report_area -nosplit > ${DC_REPORTS_DIR}/${DCRM_FINAL_AREA_REPORT}
}

report_cell -nosplit > ${DC_REPORTS_DIR}/${DESIGN_NAME}.cell.rpt
report_reference -nosplit -hierarchy > ${DC_REPORTS_DIR}/${DESIGN_NAME}.reference.rpt
report_hierarchy -nosplit > ${DC_REPORTS_DIR}/${DESIGN_NAME}.hierarchy.rpt

# Report the following information for the constraints on the current design.
# * Whether the constraint was violated or met.
# * By how much the constraint value was violated or met.
# * The design object that was the worst violator.
report_constraint -verbose > ${DC_REPORTS_DIR}/${DESIGN_NAME}.constraint.rpt

# Lists information about the attributes of the design
report_design -nosplit > ${DC_REPORTS_DIR}/${DESIGN_NAME}.design.rpt

if {[shell_is_in_topographical_mode]} {
  # report_congestion (topographical mode only) reports estimated routing related congestion
  # after topographical mode synthesis.
  # This command requires a license for Design Compiler Graphical.

  report_congestion > ${DC_REPORTS_DIR}/${DCRM_DCT_FINAL_CONGESTION_REPORT}

  # Use the following to generate and write out a congestion map from batch mode
  # This requires a GUI session to be temporarily opened and closed so a valid DISPLAY
  # must be set in your UNIX environment.

  # MBT FIXME: disabled this; don't seem to have licenses
  # maybe revisit later
  #if {[info exists env(DISPLAY)]}
  if {0} {
    gui_start

    # Create a layout window
    set MyLayout [gui_create_window -type LayoutWindow]

    # Build congestion map in case report_congestion was not previously run
    report_congestion -build_map

    # Display congestion map in layout window
    gui_show_map -map "Global Route Congestion" -show true

    # Zoom full to display complete floorplan
    gui_zoom -window [gui_get_current_window -view] -full

    # Write the congestion map out to an image file
    # You can specify the output image type with -format png | xpm | jpg | bmp

    # The following saves only the congestion map without the legends
    gui_write_window_image -format png -file ${DC_REPORTS_DIR}/${DCRM_DCT_FINAL_CONGESTION_MAP_OUTPUT_FILE}

    # The following saves the entire congestion map layout window with the legends
    gui_write_window_image -window ${MyLayout} -format png -file ${DC_REPORTS_DIR}/${DCRM_DCT_FINAL_CONGESTION_MAP_WINDOW_OUTPUT_FILE}

    gui_stop
  } else {
    puts "Information: The DISPLAY environment variable is not set. Congestion map generation has been skipped."
  }
}

# Use SAIF file for power analysis
# read_saif -auto_map_names -input ${DESIGN_NAME}.saif -instance < DESIGN_INSTANCE > -verbose

report_power -nosplit > ${DC_REPORTS_DIR}/${DCRM_FINAL_POWER_REPORT}
# report_clock_gating -nosplit > ${DC_REPORTS_DIR}/${DCRM_FINAL_CLOCK_GATING_REPORT}

# Uncomment the next line if you include the -self_gating to the compile_ultra command
# to report the XOR Self Gating information.
# report_self_gating -nosplit > ${DC_REPORTS_DIR}/${DCRM_FINAL_SELF_GATING_REPORT}

#################################################################################
# Write out Milkyway Design for Top-Down Flow
#
# This should be the last step in the script
#################################################################################

# Note: You cannot use the Milkyway format to store design data for unmapped
# designs or non-uniquified designs. Before you use the write_milkyway command,
# run the following command:
#
# mbt: force uniqification; but note: we don't really use milkyway

uniquify -force -dont_skip_empty_designs

if {[shell_is_in_topographical_mode]} {
  # write_milkyway uses: mw_logic1_net, mw_logic0_net and mw_design_library variables from dc_setup.tcl
  write_milkyway -overwrite -output ${DCRM_FINAL_MW_CEL_NAME}

  # Location to store and retrieve snapshots
  # set icc_snapshot_storage_location "[pwd]/snapshot"

  # Creates a QoR snapshot of timing, (physical), constraints, clock, power
  # data, and (routing) on active scenarios for later inqueries with
  # query_qor_snapshot command. Information in () are not supported in Design
  # Compiler. Note there is a -zero_wire_load option to create_qor_snapshot command.
  create_qor_snapshot -name postsynth -power -show_all -max_path 5 -infeasible_paths -nosplit

  # Analyzes timing report files from existing QoR snapshots, applies any
  # specified filters, and displays the results in an appropriate format.
  # This command operates in two distinct modes:
  #   CTR (general timing) mode and CTS (clock tree synthesis) mode.
  # query_qor_snapshot -name postsynth
}

# Displays QoR information and statistics.
redirect -tee ${DC_REPORTS_DIR}/${DESIGN_NAME}.qor_summary.rpt {report_qor -summary}

source $::env(BSG_CAD_DIR)/util/synopsys/area_report.tcl
redirect -tee ${DC_REPORTS_DIR}/${DESIGN_NAME}.hier_area.rpt {area_report -level 10}


exit
