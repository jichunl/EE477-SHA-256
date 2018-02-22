#################################################################################
# PrimeTime Reference Methodology Script
# Script: pt.tcl
# Version: G-2012.06 (July 2, 2012)
# Copyright (C) 2008-2012 Synopsys All rights reserved.
################################################################################

##################################################################
#    Source pt_setup.tcl File                                    #
##################################################################

source ./rm_setup/pt_setup.tcl

##################################################################
#    PrimeTime Working Mode                                      #
##################################################################

set sh_enable_page_mode          true
set timing_update_status_level   high
set timing_report_status_level   high
set si_noise_update_status_level high

set pt_mode "[string tolower [getenv PT_MODE]]"

if {$pt_mode == "si"} {
  puts "Info: Running PrimeTime for Signal Integrity Analysis."
} else {
  puts "Info: Running PrimeTime for Regular Static Timing Analysis."
}

##################################################################
#    Search Path, Library and Operating Condition Section        #
##################################################################

# Under normal circumstances, when executing a script with source, Tcl errors
# (syntax and semantic) cause the execution of the script to terminate.
# Uncomment the following line to set sh_continue_on_error to true to allow
# processing to continue when errors occur.
#
# set sh_continue_on_error true

if {$pt_mode == "si"} {
  set_app_var si_enable_analysis                true
  set_app_var si_xtalk_double_switching_mode    clock_network
}

set power_enable_analysis true 
set power_enable_multi_rail_analysis true 
set power_analysis_mode averaged

set_app_var report_default_significant_digits 3
set_app_var sh_source_uses_search_path        true
set_app_var search_path                       ". $search_path"

##################################################################
#    Netlist Reading Section                                     #
##################################################################

set_app_var link_path "* $link_path"

if {$PT_DESIGN_INPUT == "MW" } {
  read_milkyway -library $MW_DESIGN_LIBRARY $PT_INPUT_CEL
  current_design $DESIGN_NAME
}
if {$PT_DESIGN_INPUT == "VERILOG" } {
  read_verilog $NETLIST_FILES
  current_design $DESIGN_NAME
  link
}

##################################################################
#    Back Annotation Section                                     #
##################################################################

if { [info exists PARASITIC_PATHS] && [info exists PARASITIC_FILES] } {
  remove_resistance  [get_nets -hierarchical *]
  remove_capacitance [get_nets -hierarchical *]
  foreach para_path $PARASITIC_PATHS para_file $PARASITIC_FILES {
    if {$pt_mode == "si"} {
      puts "Info: Reading Parasitics with Coupling Capacitance."
      if {[string compare $para_path $DESIGN_NAME] == 0} {
        # Strings Equal
        read_parasitics -verbose -keep_capacitive_coupling -format $para_format $para_file
      } else {
        read_parasitics -verbose -path $para_path -keep_capacitive_coupling -format $para_format $para_file
      }
    } else {
      puts "Info: Reading Parasitics without Coupling Capacitance."
      if {[string compare $para_path $DESIGN_NAME] == 0} {
        # Strings Equal
        read_parasitics -verbose -format $para_format $para_file
      } else {
        read_parasitics -verbose -path $para_path -format $para_format $para_file
      }
    }
  }
}

##################################################################
#    Reading Constraints Section                                 #
##################################################################
if  {[info exists CONSTRAINT_FILES]} {
  foreach constraint_file $CONSTRAINT_FILES {
    if {[file extension $constraint_file] eq ".sdc"} {
      read_sdc -echo $constraint_file
    } else {
      source -echo $constraint_file
    }
  }
}

##################################################################
#    Update_timing and check_timing Section                      #
##################################################################

update_timing -full

# Ensure design is properly constrained
check_timing -verbose > $PT_REPORTS_DIR/${corner_case}/${DESIGN_NAME}.${PT_INPUT_CEL}.${pt_mode}.check_timing.rpt

##################################################################
#    Report_timing Section                                       #
##################################################################
if {$pt_mode == "si"} {
  report_timing -crosstalk_delta \
                -nworst 10 \
                -delay max -nosplit \
                -input_pins -nets \
                -sort_by group \
                -significant_digits ${report_default_significant_digits} \
                                           > $PT_REPORTS_DIR/${corner_case}/${DESIGN_NAME}.${PT_INPUT_CEL}.${pt_mode}.report_timing.max.rpt
  report_timing -crosstalk_delta \
                -nworst 10 \
                -delay min -nosplit \
                -input_pins -nets \
                -sort_by group \
                -significant_digits ${report_default_significant_digits} \
                                           > $PT_REPORTS_DIR/${corner_case}/${DESIGN_NAME}.${PT_INPUT_CEL}.${pt_mode}.report_timing.min.rpt
} else {
  report_timing -delay max -nosplit \
                -nworst 10 \
                -input_pins -nets \
                -sort_by group \
                -significant_digits ${report_default_significant_digits} \
                                           > $PT_REPORTS_DIR/${corner_case}/${DESIGN_NAME}.${PT_INPUT_CEL}.${pt_mode}.report_timing.max.rpt
  report_timing -delay min -nosplit \
                -nworst 10 \
                -input_pins -nets \
                -sort_by group \
                -significant_digits ${report_default_significant_digits} \
                                           > $PT_REPORTS_DIR/${corner_case}/${DESIGN_NAME}.${PT_INPUT_CEL}.${pt_mode}.report_timing.min.rpt
}

##################################################################  
##    Power Switching Activity Annotation Section                 #  
###################################################################  
read_vcd $ACTIVITY_FILE -strip_path $STRIP_PATH
report_switching_activity -list_not_annotated           

###################################################################
##    Power Analysis Section                                      #
###################################################################
### run power analysis
check_power   > $PT_REPORTS_DIR/${corner_case}/${DESIGN_NAME}.${PT_INPUT_CEL}.${pt_mode}.check_power.rpt
update_power  

### report_power
report_power -verbose > $PT_REPORTS_DIR/${corner_case}/${DESIGN_NAME}.${PT_INPUT_CEL}.${pt_mode}.report_power.summary.rpt
report_power -verbose -hierarchy > $PT_REPORTS_DIR/${corner_case}/${DESIGN_NAME}.${PT_INPUT_CEL}.${pt_mode}.report_power.hierarchy.rpt


if {[file exists [which ${DESIGN_SPECIFIC_REPORT_TIMING}]]} {
  source -echo -verbose ${DESIGN_SPECIFIC_REPORT_TIMING}
}

report_constraints -all_violators -verbose > $PT_REPORTS_DIR/${corner_case}/${DESIGN_NAME}.${PT_INPUT_CEL}.${pt_mode}.report_constraints.rpt
report_design                              > $PT_REPORTS_DIR/${corner_case}/${DESIGN_NAME}.${PT_INPUT_CEL}.${pt_mode}.report_design.rpt
report_net                                 > $PT_REPORTS_DIR/${corner_case}/${DESIGN_NAME}.${PT_INPUT_CEL}.${pt_mode}.report_net.rpt
report_clock -skew -attribute              > $PT_REPORTS_DIR/${corner_case}/${DESIGN_NAME}.${PT_INPUT_CEL}.${pt_mode}.report_clock.rpt
report_analysis_coverage -nosplit \
                  -status_details violated > $PT_REPORTS_DIR/${corner_case}/${DESIGN_NAME}.${PT_INPUT_CEL}.${pt_mode}.report_analysis_coverage.rpt
report_qor                                 > $PT_REPORTS_DIR/${corner_case}/${DESIGN_NAME}.${PT_INPUT_CEL}.${pt_mode}.qor.rpt

if {$pt_mode == "si"} {
  # Clock Network Double Switching Report
  report_si_double_switching -nosplit -rise -fall > $PT_REPORTS_DIR/${corner_case}/${DESIGN_NAME}.${PT_INPUT_CEL}.${pt_mode}.report_si_double_switching.rpt

  # Noise Margin Settings
  foreach_in_collection lib [get_libs] {
    set_noise_margin -above -low  $noise_margin_above_low  [get_lib_pins [get_attribute $lib full_name]/*/* -filter "pin_direction==in"]
    set_noise_margin -below -high $noise_margin_below_high [get_lib_pins [get_attribute $lib full_name]/*/* -filter "pin_direction==in"]
  }

  # Noise Parameter Settings
  set_noise_parameters -enable_propagation -include_beyond_rails

  # Check whether there are necessary data available to run the update_noise command.
  check_noise

  # Performs static crosstalk noise analysis.
  update_noise

  # Noise Reporting
  report_noise -nosplit -verbose -all_violators -above -low   > $PT_REPORTS_DIR/${corner_case}/${DESIGN_NAME}.${PT_INPUT_CEL}.${pt_mode}.report_noise_all_viol_above_low.rpt
  report_noise -nosplit -verbose -clock_pins -above -low      > $PT_REPORTS_DIR/${corner_case}/${DESIGN_NAME}.${PT_INPUT_CEL}.${pt_mode}.report_noise_clk_pins_above_low.rpt
  report_noise -nosplit -verbose -nworst 10 -above -low       > $PT_REPORTS_DIR/${corner_case}/${DESIGN_NAME}.${PT_INPUT_CEL}.${pt_mode}.report_noise_above_low.rpt

  report_noise -nosplit -verbose -all_violators -below -high  > $PT_REPORTS_DIR/${corner_case}/${DESIGN_NAME}.${PT_INPUT_CEL}.${pt_mode}.report_noise_all_viol_below_high.rpt
  report_noise -nosplit -verbose -clock_pins -below -high     > $PT_REPORTS_DIR/${corner_case}/${DESIGN_NAME}.${PT_INPUT_CEL}.${pt_mode}.report_noise_clk_pins_below_high.rpt
  report_noise -nosplit -verbose -nworst 10 -below -high      > $PT_REPORTS_DIR/${corner_case}/${DESIGN_NAME}.${PT_INPUT_CEL}.${pt_mode}.report_noise_below_high.rpt

  report_si_bottleneck -nosplit -cost_type delta_delay        > $PT_REPORTS_DIR/${corner_case}/${DESIGN_NAME}.${PT_INPUT_CEL}.${pt_mode}.report_si_bottleneck.rpt
  report_si_bottleneck -nosplit -cost_type delta_delay_ratio >> $PT_REPORTS_DIR/${corner_case}/${DESIGN_NAME}.${PT_INPUT_CEL}.${pt_mode}.report_si_bottleneck.rpt
  report_si_bottleneck -cost_type delay_bump_per_aggressor   >> $PT_REPORTS_DIR/${corner_case}/${DESIGN_NAME}.${PT_INPUT_CEL}.${pt_mode}.report_si_bottleneck.rpt

  report_clock_timing -nosplit -verbose \
                      -crosstalk_delta -type skew             > $PT_REPORTS_DIR/${corner_case}/${DESIGN_NAME}.${PT_INPUT_CEL}.${pt_mode}.report_clock_timing.rpt
}

write_sdf -significant_digits 6 $PT_RESULTS_DIR/${DESIGN_NAME}.${PT_INPUT_CEL}.${pt_mode}.${corner_case}.sdf
save_session $PT_RESULTS_DIR/${DESIGN_NAME}.${PT_INPUT_CEL}.${pt_mode}.${corner_case}.session

if {$pt_mode == "si"} {
  puts "Info: PrimeTime Completed Signal Integrity Analysis."
} else {
  puts "Info: PrimeTime Completed Regular Static Timing Analysis."
}

exit
