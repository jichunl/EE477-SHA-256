##########################################################################################
# Version: G-2012.06-SP4 (Jan 11, 2013)
# Copyright (C) 2007-2013 Synopsys, Inc. All rights reserved.
##########################################################################################

source -echo ./rm_setup/icc_setup.tcl

#######################################
## Outputs Script
#######################################

set ICC_OUTPUT_CEL "[getenv ICC_OUTPUT_CEL]"

## Open Design
open_mw_cel $ICC_OUTPUT_CEL -lib $MW_DESIGN_LIBRARY

## Change Names
change_names -rules verilog -hierarchy
# save_mw_cel -as ${ICC_OUTPUT_CEL}_output
# close_mw_cel
# open_mw_cel ${ICC_OUTPUT_CEL}_output

## Verilog
if {$ICC_WRITE_FULL_CHIP_VERILOG} {
  write_verilog -diode_ports -macro_definition -no_physical_only_cells $RESULTS_DIR/$DESIGN_NAME.$ICC_OUTPUT_CEL.output.v

  ## For comparison with a Design Compiler netlist,the option -diode_ports is removed
  write_verilog -macro_definition -no_physical_only_cells $RESULTS_DIR/$DESIGN_NAME.$ICC_OUTPUT_CEL.output.dc.v

  ## For LVS use,the option -no_physical_only_cells is removed
  write_verilog -macro_definition -diode_ports -pg $RESULTS_DIR/$DESIGN_NAME.$ICC_OUTPUT_CEL.output.pg.v

  ## For LVS use.
  set write_verilog_extra_opts {}
  if {[info exists ICC_FULL_VERILOG_FORCE_OUTPUT_REFERENCES]} {
    if {$ICC_FULL_VERILOG_FORCE_OUTPUT_REFERENCES != ""} {
      lappend write_verilog_extra_opts  "-force_output_references" $ICC_FULL_VERILOG_FORCE_OUTPUT_REFERENCES
    }
  }
  if {[info exists ICC_FULL_VERILOG_FORCE_NO_OUTPUT_REFERENCES]} {
    if {$ICC_FULL_VERILOG_FORCE_NO_OUTPUT_REFERENCES != ""} {
      lappend write_verilog_extra_opts "-force_no_output_references" $ICC_FULL_VERILOG_FORCE_NO_OUTPUT_REFERENCES
    }
  }
  eval "write_verilog -split_bus -macro_definition -diode_ports -pg $write_verilog_extra_opts $RESULTS_DIR/$DESIGN_NAME.$ICC_OUTPUT_CEL.output.pg.lvs.v"
} else {
  write_verilog -diode_ports -no_physical_only_cells $RESULTS_DIR/$DESIGN_NAME.$ICC_OUTPUT_CEL.output.v

  ## For comparison with a Design Compiler netlist,the option -diode_ports is removed
  write_verilog -no_physical_only_cells $RESULTS_DIR/$DESIGN_NAME.$ICC_OUTPUT_CEL.output.dc.v
}

## For Prime Time use,to include DCAP cells for leakage power analysis, add the option -force_output_references
#  if {$ICC_WRITE_FULL_CHIP_VERILOG} {
#    write_verilog -diode_ports -no_physical_only_cells -force_output_references [list of your DCAP cells] $RESULTS_DIR/$DESIGN_NAME.$ICC_OUTPUT_CEL.output.pt.v -macro_definition
#  } else {
#    write_verilog -diode_ports -no_physical_only_cells -force_output_references [list of your DCAP cells] $RESULTS_DIR/$DESIGN_NAME.$ICC_OUTPUT_CEL.output.pt.v
#  }

## SDC
set_app_var write_sdc_output_lumped_net_capacitance false
set_app_var write_sdc_output_net_resistance false

write_sdc $RESULTS_DIR/$DESIGN_NAME.$ICC_OUTPUT_CEL.output.sdc

extract_rc -coupling_cap
# write_parasitics -format SPEF -output $RESULTS_DIR/$DESIGN_NAME.$ICC_OUTPUT_CEL.output.spef
write_parasitics -format SBPF -output $RESULTS_DIR/$DESIGN_NAME.$ICC_OUTPUT_CEL.output.sbpf

## DEF
write_def -output $RESULTS_DIR/$DESIGN_NAME.$ICC_OUTPUT_CEL.output.def

## SDF
write_sdf -significant_digits 8 $RESULTS_DIR/$DESIGN_NAME.$ICC_OUTPUT_CEL.output.sdf

## GDS
# Set options - usually also include a mapping file (-map_layer)
set_write_stream_options \
  -map_layer $GDSII_OUT_LAYER_MAP \
  -output_pin {text geometry} \
  -output_polygon_pin \
  -remove_backslash_from_instance_net_names \
  -child_depth 0 \
  -output_filling fill \
  -output_geometry_property \
  -output_outdated_fill \
  -flatten_via \
  -keep_data_type
write_stream -lib_name $MW_DESIGN_LIBRARY -cells ${ICC_OUTPUT_CEL} -format $WRITE_STREAM_FORMAT $RESULTS_DIR/$DESIGN_NAME.$ICC_OUTPUT_CEL.output.gds

if {$ICC_CREATE_MODEL} {
  save_mw_cel -as $DESIGN_NAME
  close_mw_cel
  open_mw_cel $DESIGN_NAME

  source -echo common_optimization_settings_icc.tcl
  source -echo common_placement_settings_icc.tcl
  source -echo common_post_cts_timing_settings.tcl
  source -echo common_route_si_settings_zrt_icc.tcl

  create_macro_fram
  if {$ICC_FIX_ANTENNA} {
  ## create Antenna Info
    extract_zrt_hier_antenna_property -cell_name $DESIGN_NAME
  }

  if {$ICC_CREATE_BLOCK_ABSTRACTION} {
    create_block_abstraction
    save_mw_cel
  } else {
    create_ilm -include_xtalk
  }

  ## Validating ILM using write_interface_timing and compare_interface_timing:
  #   write_interface_timing cel.rpt
  #   close_mw_cel
  #   open_mw_cel $DESIGN_NAME.ILM
  #   write_interface_timing ilm.rpt
  #   compare_interface_timing -nosplit cel.rpt ilm.rpt -output compare_interface_timing.rpt
  #   close_mw_cel
  #   open_mw_cel $DESIGN_NAME

  close_mw_cel
}

exit
