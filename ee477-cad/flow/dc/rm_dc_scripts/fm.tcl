source -echo -verbose ./rm_setup/dc_setup.tcl
source -echo -verbose ./rm_setup/fm_setup.tcl

#################################################################################
# Formality Verification Script for
# Design Compiler Reference Methodology Script for Top-Down Flow
# Script: fm.tcl
# Version: G-2012.06-SP4 (January 11, 2013)
# Copyright (C) 2007-2013 Synopsys, Inc. All rights reserved.
#################################################################################

#################################################################################
# Synopsys Auto Setup Mode
#################################################################################

set_app_var synopsys_auto_setup true

# Note: The Synopsys Auto Setup mode is less conservative than the Formality
# default mode, and is more likely to result in a successful verification
# out-of-the-box.
#
# Using the Setting this variable will change the default values of the
# variables listed here below You may change any of these variables back to
# their default settings to be more conservative. Uncomment the appropriate
# lines below to revert back to their default settings:

  # set_app_var hdlin_ignore_parallel_case true
  # set_app_var hdlin_ignore_full_case true
  # set_app_var verification_verify_directly_undriven_output true
  # set_app_var hdlin_ignore_embedded_configuration false
  # set_app_var svf_ignore_unqualified_fsm_information true
  # set_app_var signature_analysis_allow_subset_match true

# Other variables with changed default values are described in the next few sections.

#################################################################################
# Setup for handling undriven signals in the design
#################################################################################

# The Synopsys Auto Setup mode sets undriven signals in the reference design to
# "0" or "BINARY" (as done by DC), and the undriven signals in the impl design are
# forced to "BINARY". This is done with the following setting:

  # set_app_var verification_set_undriven_signals synthesis

# Uncomment the next line to revert back to the more conservative default setting:

  # set_app_var verification_set_undriven_signals BINARY:X

#################################################################################
# Setup for simulation/synthesis mismatch messaging
#################################################################################

# The Synopsys Auto Setup mode will produce warning messages, not error messages,
# when Formality encounters potential differences between simulation and synthesis.
# Uncomment the next line to revert back to the more conservative default setting:

  # set_app_var hdlin_error_on_mismatch_message true

#################################################################################
# Setup for Clock-gating
#################################################################################

# The Synopsys Auto Setup mode, along with the SVF file, will appropriately set
# the clock-gating variable. Otherwise, the user will need to notify Formality
# of clock-gating by uncommenting the next line:

  # set_app_var verification_clock_gate_hold_mode any

#################################################################################
# Setup for instantiated DesignWare or function-inferred DesignWare components
#################################################################################

# The Synopsys Auto Setup mode, along with the SVF file, will automatically set
# the hdlin_dwroot variable to the top-level of the Design Compiler tree used
# for synthesis. Otherwise, the user will need to set this variable if the
# design contains instantiated DW or function-inferred DW.
#
# Enter the pathname to the top-level of the DC tree
set_app_var hdlin_dwroot "[getenv DC_RELEASE]"

#################################################################################
# Setup for handling missing design modules
#################################################################################

# If the design has missing blocks or missing components in both the reference
# and implementation designs, uncomment the following variable so that
# Formality can complete linking each design:

  # set_app_var hdlin_unresolved_modules black_box

#################################################################################
# Read in the SVF file(s)
#################################################################################

# Set this variable to point to individual SVF file(s) or to a directory containing SVF files.

set_svf ${DC_RESULTS_DIR}/${DCRM_SVF_OUTPUT_FILE}

report_guidance -summary

#################################################################################
# Read in the libraries
#################################################################################

foreach tech_lib "${TARGET_LIBRARY_FILES} ${ADDITIONAL_LINK_LIB_FILES}" {
  read_db -technology_library $tech_lib -libname ${FM_LIB_NAME}_tech
}

#################################################################################
# Read in the Reference Design as verilog/vhdl source code
#################################################################################

# The following setting allows the read script to be found in the search path
set_app_var sh_source_uses_search_path true

puts "RM-Info: Sourcing script file [which ${FMRM_RTL_READ_SCRIPT}]\n"

source -echo -verbose ${FMRM_RTL_READ_SCRIPT}

set_top r:/${FM_LIB_NAME}/${DESIGN_NAME}

#################################################################################
# Read in the Implementation Design from DC-RM results
#
# Choose the format that is used in your flow.
#################################################################################

# For Verilog
#read_verilog -i ${DC_RESULTS_DIR}/${DCRM_FINAL_VERILOG_OUTPUT_FILE} -libname ${FM_LIB_NAME}

# OR

# For .ddc
read_ddc -i ${DC_RESULTS_DIR}/${DCRM_FINAL_DDC_OUTPUT_FILE} -libname ${FM_LIB_NAME}

# OR

# For Milkyway

# The -no_pg option should be used for MW designs from DC to prevent automatic
# linking to power aware versions of the cells.

# read_milkyway -i -no_pg -libname WORK -cell_name ${DCRM_FINAL_MW_CEL_NAME} ${mw_design_library} -libname ${FM_LIB_NAME}

set_top i:/${FM_LIB_NAME}/${DESIGN_NAME}

#################################################################################
# Configure constant ports
#
# When using the Synopsys Auto Setup mode, the SVF file will convey information
# automatically to Formality about how to disable scan.
#
# Otherwise, manually define those ports whose inputs should be assumed constant
# during verification.
#
# Example command format:
#
#   set_constant -type port i:/WORK/${DESIGN_NAME}/<port_name> <constant_value>
#
#################################################################################

#################################################################################
# Report design statistics, design read warning messages, and user specified setup
#################################################################################

# report_setup_status will create a report showing all design statistics,
# design read warning messages, and all user specified setup. This will allow
# the user to check all setup before proceeding to run the more time consuming
# commands "match" and "verify".

report_setup_status > ${FM_REPORTS_DIR}/${FM_LIB_NAME}/${DESIGN_NAME}.fmv_setup_status.rpt

report_black_boxes > ${FM_REPORTS_DIR}/${FM_LIB_NAME}/${DESIGN_NAME}.fmv_black_boxes.rpt

#################################################################################
# Match compare points and report unmatched points
#################################################################################

match

report_matched_points > ${FM_REPORTS_DIR}/${FM_LIB_NAME}/${DESIGN_NAME}.fmv_matched_points.rpt
report_user_matches > ${FM_REPORTS_DIR}/${FM_LIB_NAME}/${DESIGN_NAME}.fmv_user_matches.rpt
report_unmatched_points > ${FM_REPORTS_DIR}/${FM_LIB_NAME}/${DESIGN_NAME}.fmv_unmatched_points.rpt
report_not_compared_points > ${FM_REPORTS_DIR}/${FM_LIB_NAME}/${DESIGN_NAME}.fmv_not_compared_points.rpt

#################################################################################
# Verify and Report
#
# If the verification is not successful, the session will be saved and reports
# will be generated to help debug the failed or inconclusive verification.
#################################################################################

if { ![verify] } {
  save_session -replace ${FM_REPORTS_DIR}/${FM_LIB_NAME}/${DESIGN_NAME}
  report_failing_points > ${FM_REPORTS_DIR}/${FM_LIB_NAME}/${DESIGN_NAME}.fmv_failing_points.rpt
  report_aborted_points > ${FM_REPORTS_DIR}/${FM_LIB_NAME}/${DESIGN_NAME}.fmv_aborted_points.rpt
  # Use analyze_points to help determine the next step in resolving verification
  # issues. It runs heuristic analysis to determine if there are potential causes
  # other than logical differences for failing or hard verification points.
  analyze_points -all > ${FM_REPORTS_DIR}/${FM_LIB_NAME}/${DESIGN_NAME}.fmv_analyze_points.rpt
  report_analysis_results > ${FM_REPORTS_DIR}/${FM_LIB_NAME}/${DESIGN_NAME}.fmv_analysis_results.rpt
  diagnose
  report_error_candidates > ${FM_REPORTS_DIR}/${FM_LIB_NAME}/${DESIGN_NAME}.fmv_error_candidates.rpt
  set fm_passed FALSE
} else {
  set fm_passed TRUE
}

report_unverified_points > ${FM_REPORTS_DIR}/${FM_LIB_NAME}/${DESIGN_NAME}.fmv_unverified_points.rpt

report_app_var > ${FM_REPORTS_DIR}/${FM_LIB_NAME}/${DESIGN_NAME}.fmv_app_var.rpt

exit
