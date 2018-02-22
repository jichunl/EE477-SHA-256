##########################################################################################
# Version: G-2012.06-SP4 (Jan 11, 2013)
# Copyright (C) 2007-2013 Synopsys, Inc. All rights reserved.
##########################################################################################

source -echo ./rm_setup/icc_setup.tcl

##########################################################################################
## place_opt_icc: Placement and Placement Optimizations
##########################################################################################
open_mw_lib $MW_DESIGN_LIBRARY
redirect /dev/null "remove_mw_cel -version_kept 0 ${ICC_PLACE_OPT_CEL}"
copy_mw_cel -from $ICC_FLOORPLAN_CEL -to $ICC_PLACE_OPT_CEL
open_mw_cel $ICC_PLACE_OPT_CEL

## Optimization Common Session options - set in all sessions
source -echo common_optimization_settings_icc.tcl
source -echo common_placement_settings_icc.tcl

## Source CTS Options CTS can be run during place_opt
source -echo common_cts_settings_icc.tcl

## Set Ideal Network so place_opt doesn't buffer clock nets
## Remove before clock_opt cts
## Uncertainty handling pre-cts
set_ideal_network [all_fanout -flat -clock_tree ]

if {$ICC_APPLY_RM_UNCERTAINTY_PRECTS && [file exists [which $ICC_UNCERTAINTY_PRECTS_FILE]] } {
  echo "RM-Info: Sourcing the pre-cts uncertainty file : [which $ICC_UNCERTAINTY_PRECTS_FILE]"
  source -echo $ICC_UNCERTAINTY_PRECTS_FILE
}

set_app_var compile_instance_name_prefix icc_place

#######################
## MAGNET PLACEMENT  ##
#######################
## Define e.g. a ram as a magnet and the command will pull the cells connected to this instance
## closer to the magnet, depending on the -logical_level amount you provide.
## When adding the -exclude_buffers option, you instruct the tool to pull buffers as well, but do not consider them in the
## logical levels calculation

#magnet_placement -exclude_buffers -logical_level 2 [get_cells "INST_RAM1 INST_RAM2"]

if {$MAGNET_PLACEMENT_CELLS != "" } {
  magnet_placement -exclude_buffers -logical_level $MAGNET_PLACEMENT_LEVELS [get_cells $MAGNET_PLACEMENT_CELLS]
}

##############################
## RP : Relative Placement  ##
##############################
## Create RP constraints as shown below
#create_rp_group Lachd_Result_reg -design ORCA -columns 1 -rows 8 -utilization 1.000000
#add_to_rp_group ORCA::Lachd_Result_reg -leaf I_ORCA_TOP/I_RISC_CORE/I_ALU/Lachd_Result_reg_0_ -column 0 -row 0
#add_to_rp_group ORCA::Lachd_Result_reg -leaf I_ORCA_TOP/I_RISC_CORE/I_ALU/Lachd_Result_reg_1_ -column 0 -row 1
#add_to_rp_group ORCA::Lachd_Result_reg -leaf I_ORCA_TOP/I_RISC_CORE/I_ALU/Lachd_Result_reg_2_ -column 0 -row 2
#add_to_rp_group ORCA::Lachd_Result_reg -leaf I_ORCA_TOP/I_RISC_CORE/I_ALU/Lachd_Result_reg_3_ -column 0 -row 3
#add_to_rp_group ORCA::Lachd_Result_reg -leaf I_ORCA_TOP/I_RISC_CORE/I_ALU/Lachd_Result_reg_4_ -column 0 -row 4
#add_to_rp_group ORCA::Lachd_Result_reg -leaf I_ORCA_TOP/I_RISC_CORE/I_ALU/Lachd_Result_reg_5_ -column 0 -row 5
#add_to_rp_group ORCA::Lachd_Result_reg -leaf I_ORCA_TOP/I_RISC_CORE/I_ALU/Lachd_Result_reg_6_ -column 0 -row 6
#add_to_rp_group ORCA::Lachd_Result_reg -leaf I_ORCA_TOP/I_RISC_CORE/I_ALU/Lachd_Result_reg_7_ -column 0 -row 7

## Other commands that can be used for RP group creation are : extract_rp_group and order_rp_groups
#extract_rp_group -group_name Lachd_Result_reg -objects [get_cells -hier Lachd_Result_reg*] -col 1 -apply
#extract_rp_group -group_name Oprnd_A_reg -objects [get_cells -hier Oprnd_A_reg*] -col 1 -apply
#extract_rp_group -group_name Oprnd_B_reg -objects [get_cells -hier Oprnd_B_reg*] -col 1 -apply
#order_rp_group -group_name Oprnd_reg {ORCA::Oprnd_A_reg ORCA::Oprnd_B_reg} -apply

## Set spacing labels - to set internal spacing constraint on a reference cell, refer to the following example :
#  set_lib_cell_spacing_label -names {your_labels} -right_lib_cells {lib_cells} -left_lib_cells {lib_cells}

## Set spacing rules - to set internal spacing constraint between reference cells assigned with spacing labels,
#  refer to the following example :
#  set_spacing_label_rule -labels {your_label1 your_label2} {illegal_spacing_min illegal_spacing_max}
#  set_spacing_label_rule -labels {your_label1 SNPS_BOUNDARY} {illegal_spacing_min illegal_spacing_max}
################################################################################
## Save the environment snapshot for the Consistency Checker utility.
#
#  This utility checks for inconsistent settings between Design Compiler and
#  IC Compiler which can contribute to correlation mismatches.
#  Download this utility from SolvNet. See the following SolvNet article for
#  complete details: https://solvnet.synopsys.com/retrieve/026366.html
#  Uncomment the following lines to snapshot the environment.
# write_environment -consistency -output $RESULTS_DIR/${ICC_PLACE_OPT_CEL}.write_environment
################################################################################

if {$ICC_ENABLE_CHECKPOINT} {
  echo "RM-Info : Please ensure there's enough disk space before enabling the set_checkpoint_strategy feature."

  # The -overwrite option is used by default. Remove it if needed.
  set_checkpoint_strategy -enable -overwrite
}

if {[file exists [which $CUSTOM_PLACE_OPT_PRE_SCRIPT]]} {
  echo "RM-Info: Sourcing [which $CUSTOM_PLACE_OPT_PRE_SCRIPT]"
  source $CUSTOM_PLACE_OPT_PRE_SCRIPT
}

set place_opt_cmd "place_opt -area_recovery -effort $PLACE_OPT_EFFORT"

if {$PLACE_OPT_CONGESTION_DRIVEN} {lappend place_opt_cmd -congestion}
if {$DFT && [get_scan_chain] != 0} {lappend place_opt_cmd -optimize_dft}
if {!$DFT && [get_scan_chain] == 0} {lappend place_opt_cmd -continue_on_missing_scandef}
if {$POWER_OPTIMIZATION} {lappend place_opt_cmd -power}

echo $place_opt_cmd
eval $place_opt_cmd

## To display verbose message during DRC fixing,  hold fixing, multiple-port-net fixing and tie-off optimization
#  in preroute stage, set the following before place_opt :
#    Off (default)        : set_app_var preroute_opt_verbose 0
#    General              : set_app_var preroute_opt_verbose 1
#    DRC                  : set_app_var preroute_opt_verbose 2
#    Hold                 : set_app_var preroute_opt_verbose 4
#    General + DRC + hold : set_app_var preroute_opt_verbose 7
#    Tie-off              : set_app_var preroute_opt_verbose 8
#    Multiple port nets   : set_app_var preroute_opt_verbose 16

if {[file exists [which $CUSTOM_PLACE_OPT_POST_SCRIPT]]} {
  echo "RM-Info: Sourcing [which $CUSTOM_PLACE_OPT_POST_SCRIPT]"
  source $CUSTOM_PLACE_OPT_POST_SCRIPT
}

if {$ICC_ENABLE_CHECKPOINT} {set_checkpoint_strategy -disable}

if { [check_error -verbose] != 0} { echo "RM-Error, flagging ..." }

if {$PLACE_OPT_PREROUTE_FOCALOPT_LAYER_OPTIMIZATION} {
  # For advanced technologies, where upper metal layer resistance values are
  # much smaller then lower layer ones, you can perform layer optimization to
  # improve existing buffer trees. Use set_preroute_focal_opt_strategy to
  # customize the settings.
  report_preroute_focal_opt_strategy
  preroute_focal_opt -layer_optimization
}

##############################
## RP : Relative Placement  ##
##############################
## Checking any RP violations.
## It is recommended to open up the GUI and bring up the RP hierarchical browser and
## RP visual mode to see if RP groups were created correctly

# mbt: see what's going on.
all_rp_groups
check_rp_groups -all

##############################
## Spare Cell Insertion     ##
##############################
# There are basically two kinds of ECO flows: unconstrained ECO and
# freeze-silicon ECO. They are also called all-layer ECO and metal-mask ECO
# respectively. In unconstrained ECO flow it is possible to add or delete
# standard cells and update connections. This kind of ECO is typically done
# before tapeout, it can be used to fix logic bugs or timing issues without too
# much disturbances to the existing chip layout. Unconstrained ECO can also be
# done after tapout; in this case there is no saving in mask production costs,
# but the re-design time can be reduced if required changes are minimal. There
# is actually no concept of "spare cells" in this flow because all existing
# cells are in active use.
#
# Freeze-silicon ECO is typically done after tapout, when the silicon layer
# masks are not allowed to change, and only metal layer masks change using
# previously inserted "spare cells". Therefore, to make this post-tapeout ECO
# possible, spare cells must be inserted and spread over the chip before the
# silicon tapeout.
#
# It depends on the foundry or tapeout service which ECO flow makes more sense.
# If the foundry does not offer freeze-silicon ECO flow, or the freeze-silicon
# ECO is as expensive as an all-layer ECO, it does not worth inserting spare
# cells here because they leak current and waste energy. If necessary, it is
# better to perform an all-layer re-spin where all cells are in active use.
# However, if the foundry supports freeze-silicon ECO and it saves a lot
# expense compared to all-layer ECO, then inserting spare cells become
# important here and the "-num_cells" of "insert_spare_cells" must be seriously
# considered.

if {$ICC_ECO_FLOW == "FREEZE_SILICON"} {
  echo "RM-Info: Starting the Freeze Silicon eco flow, inserting the spare cells"

  ## spare cell file typically contains commands like :
  ## insert_spare_cells -num_cells {ANDa 10 ANDb 20 ANDc 23} -cell_name spares

  if {[file exists [which $ICC_SPARE_CELL_FILE]]} {
    echo "RM-Info: Sourcing [which $ICC_SPARE_CELL_FILE]"
    source -echo $ICC_SPARE_CELL_FILE
  }
}

########################################
#           CONNECT P/G                #
########################################
## Connect Power & Ground for non-MV and MV-mode

if {[file exists [which $CUSTOM_CONNECT_PG_NETS_SCRIPT]]} {
  echo "RM-Info: Sourcing [which $CUSTOM_CONNECT_PG_NETS_SCRIPT]"
  source -echo $CUSTOM_CONNECT_PG_NETS_SCRIPT
} else {
  derive_pg_connection -power_net $MW_POWER_NET -power_pin $MW_POWER_PORT -ground_net $MW_GROUND_NET -ground_pin $MW_GROUND_PORT
  if {!$ICC_TIE_CELL_FLOW} {derive_pg_connection -power_net $MW_POWER_NET -ground_net $MW_GROUND_NET -tie}
}

if { [check_error -verbose] != 0} { echo "RM-Error, flagging ..." }

if {$ICC_TIE_CELL_FLOW} {
  echo "RM-Info : List of TIE-CELL instances in your design :"
  all_tieoff_cells
} else {
  report_tie_nets
}

# MBT: I added this because if we do not, the timing routines appears to use old wires that are out of date.
# as a result, you see some crazy large capacitances that don't reflect that a buffer has been inserted by
# place_opt. The larger question, though, is whether we should actually be deleting those stale wires.

remove_route_by_type -signal_global_route

# MBT: See iccn.pdf RPGP-024
# 5/11/2015
#
# The CEL parser gets upset when RP groups are listed that are no longer valid (because of optimization).
# We have to purge the stale RP groups as follows:
#
# write_rp_groups   -all -output 
# remove_rp_groups  -all
# source
#

write_rp_groups -all -output $REPORTS_DIR_PLACE_OPT/$ICC_PLACE_OPT_CEL.rp_groups.tcl
remove_rp_groups -all
source $REPORTS_DIR_PLACE_OPT/$ICC_PLACE_OPT_CEL.rp_groups.tcl

if {$ICC_REPORTING_EFFORT != "OFF" } {

  # MBT: update estimate values.
  extract_rc -estimate
  redirect -file $REPORTS_DIR_PLACE_OPT/$ICC_PLACE_OPT_CEL.max.tim {report_timing -nosplit -capacitance -transition_time -input_pins -nets -delay max}
  redirect -file $REPORTS_DIR_PLACE_OPT/$ICC_PLACE_OPT_CEL.min.tim {report_timing -nosplit -capacitance -transition_time -input_pins -nets -delay min}
}

if {$ICC_REPORTING_EFFORT == "MED" && $POWER_OPTIMIZATION } {
  redirect -file $REPORTS_DIR_PLACE_OPT/$ICC_PLACE_OPT_CEL.power {report_power -nosplit}
}

save_mw_cel -as $ICC_PLACE_OPT_CEL

## Create Snapshot and Save
if {$ICC_REPORTING_EFFORT != "OFF" } {
  create_qor_snapshot -name $ICC_PLACE_OPT_CEL
  redirect -file $REPORTS_DIR_PLACE_OPT/$ICC_PLACE_OPT_CEL.qor_snapshot.rpt {report_qor_snapshot -no_display}
}

if {$ICC_REPORTING_EFFORT == "MED" } {
  redirect -file $REPORTS_DIR_PLACE_OPT/$ICC_PLACE_OPT_CEL.placement_utilization.rpt {report_placement_utilization -verbose}
  redirect -tee -file $REPORTS_DIR_PLACE_OPT/$ICC_PLACE_OPT_CEL.qor {report_qor}
  redirect -tee -file $REPORTS_DIR_PLACE_OPT/$ICC_PLACE_OPT_CEL.qor -append {report_qor -summary}
  # redirect -tee -file $REPORTS_DIR_PLACE_OPT/$ICC_PLACE_OPT_CEL.qor -append {report_timing_histogram -range_maximum 0}
  # redirect -tee -file $REPORTS_DIR_PLACE_OPT/$ICC_PLACE_OPT_CEL.qor -append {report_timing_histogram -range_minimum 0}
  redirect -file $REPORTS_DIR_PLACE_OPT/$ICC_PLACE_OPT_CEL.con {report_constraints}
}

if {[file exists [which $ICC_SIGNOFF_OPT_CHECK_CORRELATION_PREROUTE_SCRIPT]]} {
  source $ICC_SIGNOFF_OPT_CHECK_CORRELATION_PREROUTE_SCRIPT
}

## Categorized Timing Report (CTR)
#  Use CTR in the interactive mode to view the results of create_qor_snapshot.
#  Recommended to be used with GUI opened.
#  query_qor_snapshot -display (or GUI: Timing -> Query QoR Snapshot)
#  query_qor_snapshot condenses the timing report into a cross-referencing table for quick analysis.
#  It can be used to highlight violating paths and metric in the layout window and timing reports.
#  CTR also provides special options to focus on top-level and hierarchical timing issues.
#  When dealing with dirty designs, increasing the number violations per path to 20-30 when generating a snapshot can help
#  find more issues after each run (create_qor_snapshot -max_paths 20).

exit
