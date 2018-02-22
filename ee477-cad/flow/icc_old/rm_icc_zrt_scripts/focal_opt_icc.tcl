##########################################################################################
# Version: G-2012.06-SP4 (Jan 11, 2013)
# Copyright (C) 2007-2013 Synopsys, Inc. All rights reserved.
##########################################################################################

source -echo ./rm_setup/icc_setup.tcl 

###################################################
## focal_opt_icc: focal_opt
###################################################




open_mw_lib $MW_DESIGN_LIBRARY
redirect /dev/null "remove_mw_cel -version_kept 0 ${ICC_FOCAL_OPT_CEL}"
copy_mw_cel -from $ICC_FOCAL_OPT_STARTING_CEL -to $ICC_FOCAL_OPT_CEL
open_mw_cel $ICC_FOCAL_OPT_CEL


source -echo common_optimization_settings_icc.tcl
source -echo common_placement_settings_icc.tcl
source -echo common_post_cts_timing_settings.tcl



########################################
#    LOAD THE ROUTE AND SI SETTINGS    #
########################################

source -echo common_route_si_settings_zrt_icc.tcl


if { [check_error -verbose] != 0} { echo "RM-Error, flagging ..." }

if {[file exists [which $CUSTOM_FOCAL_OPT_PRE_SCRIPT]]} {
echo "RM-Info: Sourcing [which $CUSTOM_FOCAL_OPT_PRE_SCRIPT]"
source $CUSTOM_FOCAL_OPT_PRE_SCRIPT
}

## focal_opt allows you to optimize a specific subset of post route violations for setup/hold/drc
## these violating endpoints can be provided via a simple ascii file, e.g. :
##          I_STACK_TOP/I3_STACK_MEM/Stack_Mem_reg_2__1_/D
## execute man focal_opt to find additional options

## Note :
#  For running route_opt and focal_opt with filler cells placed, the filler cells must be type std_filler.
#  This is done by marking the std filler cells with gdsStdFillerCell during library dataprep.
#  If you see the following message when filler cells are inserted prior to route_opt or focal_opt,
#  then that means they are not marked properly :
#     WARNING : cell <xxx> is not of std filler cell subtype

 if {$ICC_FOCAL_OPT_HOLD_VIOLS != ""} {
  if {[file exists [which $ICC_FOCAL_OPT_HOLD_VIOLS]]} {
    focal_opt -hold_endpoints $ICC_FOCAL_OPT_HOLD_VIOLS
  } elseif {$ICC_FOCAL_OPT_HOLD_VIOLS == "all"} {
    focal_opt -hold_endpoints all
    }
 }
 
 if {$ICC_FOCAL_OPT_SETUP_VIOLS != ""} {
  if {[file exists [which $ICC_FOCAL_OPT_SETUP_VIOLS]]} {
    focal_opt -setup_endpoints $ICC_FOCAL_OPT_SETUP_VIOLS
  } elseif {$ICC_FOCAL_OPT_SETUP_VIOLS == "all"} {
    focal_opt -setup_endpoints all
    }
 }
 
 if {$ICC_FOCAL_OPT_DRC_NET_VIOLS != ""} {
  if {[file exists [which $ICC_FOCAL_OPT_DRC_NET_VIOLS]]} {
    focal_opt -drc_nets $ICC_FOCAL_OPT_DRC_NET_VIOLS
  } elseif {$ICC_FOCAL_OPT_DRC_NET_VIOLS == "all"} {
    focal_opt -drc_nets all
    }
 }
 
 if {$ICC_FOCAL_OPT_DRC_PIN_VIOLS != ""} {
  if {[file exists [which $ICC_FOCAL_OPT_DRC_PIN_VIOLS]]} {
    focal_opt -drc_pins $ICC_FOCAL_OPT_DRC_PIN_VIOLS
  } elseif {$ICC_FOCAL_OPT_PIN_VIOLS == "all"} {
    focal_opt -drc_pins all
    }
 }
 
 if {$ICC_FOCAL_OPT_XTALK_VIOLS != ""} {
  if {[file exists [which $ICC_FOCAL_OPT_XTALK_VIOLS]]} {
    focal_opt -xtalk_reduction $ICC_FOCAL_OPT_XTALK_VIOLS
  }
 }

## TIO setup for route_opt command
if {$ICC_IMPLEMENTATION_PHASE == "top" && $ICC_CREATE_BLOCK_ABSTRACTION} {

  set_app_var tio_write_eco_changes $ICC_TIO_WRITE_ECO_FILE
  # set_app_var tio_eco_output_directory TIO_eco_changes

  set set_top_implementation_options_cmd " \
  set_top_implementation_options \
  -block_references [list $ICC_TIO_BLOCK_LIST] \
  -optimize_block_interface $ICC_TIO_OPTIMIZE_BLOCK_INTERFACE \
  "
  ## You can also add the -size_only_mode option to specify size_only settings

  ## Enable -optimize_shared_logic if -optimize_block_interface is also enabled
  if {$ICC_TIO_OPTIMIZE_BLOCK_INTERFACE && $ICC_TIO_OPTIMIZE_SHARED_LOGIC} {
    lappend set_top_implementation_options_cmd -optimize_shared_logic $ICC_TIO_OPTIMIZE_SHARED_LOGIC
  }

  ## Enable -host_options if ICC_TIO_HOST_OPTION_POOL_OPTIO and ICC_TIO_HOST_OPTION_SUBMIT_OPTIONS are both valid  
  if {($ICC_TIO_HOST_OPTION_POOL_OPTION == "lsf" || $ICC_TIO_HOST_OPTION_POOL_OPTION == "grd") && $ICC_TIO_HOST_OPTION_SUBMIT_OPTIONS != ""} {
    set_host_options -name my_tio_host_options -pool $ICC_TIO_HOST_OPTION_POOL_OPTION -submit_options $ICC_TIO_HOST_OPTION_SUBMIT_OPTIONS
    lappend set_top_implementation_options_cmd -host_options my_tio_host_options
  }
  echo $set_top_implementation_options_cmd

  ## If -optimize_block_interface is enabled and list of block references is not empty, make sure -host_options is also specified 
  if {$ICC_TIO_OPTIMIZE_BLOCK_INTERFACE && $ICC_TIO_BLOCK_LIST != ""} {

    if {$ICC_TIO_HOST_OPTION_POOL_OPTION != "" && $ICC_TIO_HOST_OPTION_SUBMIT_OPTIONS != ""} {
      eval $set_top_implementation_options_cmd
      report_top_implementation_options
      if {$ICC_SANITY_CHECK} {
        check_interface_optimization_setup
      }
    } else {
      echo "RM-Error : ICC_TIO_OPTIMIZE_BLOCK_INTERFACE is set to true and ICC_TIO_BLOCK_LIST is not empty but either ICC_TIO_HOST_OPTION_POOL_OPTION or ICC_TIO_HOST_OPTION_SUBMIT_OPTIONS is not specified. Please specify valid ICC_TIO_HOST_OPTION_POOL_OPTION and ICC_TIO_HOST_OPTION_SUBMIT_OPTIONS or route_opt will not execute. set_top_implementation_options is not executed and interface optimization will be skipped."
    }

  } else {

    eval $set_top_implementation_options_cmd
    report_top_implementation_options
    if {$ICC_SANITY_CHECK} {
      check_interface_optimization_setup
    }

  }

}

 ## The following route_opt command performs final overall optimization with -size_only option which is used
 #  to avoid potential route and cell disturbances associated with buffer insertion.
 #  Refer to SolvNet #034130 for more details about postroute design closre flow. 
 route_opt -incremental -size_only

 if {$POWER_OPTIMIZATION} {
 focal_opt -power
 }


if {[file exists [which $CUSTOM_FOCAL_OPT_POST_SCRIPT]]} {
echo "RM-Info: Sourcing [which $CUSTOM_FOCAL_OPT_POST_SCRIPT]"
source $CUSTOM_FOCAL_OPT_POST_SCRIPT
}

if {$ICC_REPORTING_EFFORT == "MED" } {
  redirect -tee -file $REPORTS_DIR_FOCAL_OPT/$ICC_FOCAL_OPT_CEL.qor {report_qor}
  redirect -tee -file $REPORTS_DIR_FOCAL_OPT/$ICC_FOCAL_OPT_CEL.qor -append {report_qor -summary}
  redirect -file $REPORTS_DIR_FOCAL_OPT/$ICC_FOCAL_OPT_CEL.con {report_constraints}
}

if {$ICC_REPORTING_EFFORT != "OFF" } {
     redirect -tee -file $REPORTS_DIR_FOCAL_OPT/$ICC_FOCAL_OPT_CEL.clock_tree {report_clock_tree -nosplit -summary}     ;# global skew report
     redirect -file $REPORTS_DIR_FOCAL_OPT/$ICC_FOCAL_OPT_CEL.clock_timing {report_clock_timing -nosplit -type skew} ;# local skew report
}
if {$ICC_REPORTING_EFFORT != "OFF" } {
 redirect -file $REPORTS_DIR_FOCAL_OPT/$ICC_FOCAL_OPT_CEL.max.tim {report_timing -nosplit -crosstalk_delta -capacitance -transition_time -input_pins -nets -delay max} 
 redirect -file $REPORTS_DIR_FOCAL_OPT/$ICC_FOCAL_OPT_CEL.min.tim {report_timing -nosplit -crosstalk_delta -capacitance -transition_time -input_pins -nets -delay min} 
}
if {$ICC_REPORTING_EFFORT != "OFF" } {
 redirect -tee -file $REPORTS_DIR_FOCAL_OPT/$ICC_FOCAL_OPT_CEL.sum {report_design_physical -all -verbose}
}

save_mw_cel -as $ICC_FOCAL_OPT_CEL


## Create Snapshot and Save

if {$ICC_REPORTING_EFFORT != "OFF" } {
 create_qor_snapshot -name $ICC_FOCAL_OPT_CEL
 redirect -file $REPORTS_DIR_FOCAL_OPT/$ICC_FOCAL_OPT_CEL.qor_snapshot.rpt {report_qor_snapshot -no_display}
}

exit

