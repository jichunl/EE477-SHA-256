
source $::env(BSG_DESIGNS_TARGET_DIR)/tcl/filelist.tcl
set bsg_chip_sub_design_dir $::env(BSG_CHIP_SUB_DESIGN_DIR)

#
# this file replaces the above generic files with process-specific hardened IP
# sets the variables asic_hard_filelist and NETLIST_SOURCE_FILES
#

source $::env(BSG_DESIGNS_TARGET_DIR)/tcl/hard/$::env(BSG_DESIGNS_HARD_TARGET)/filelist_deltas.tcl

# file replacement

proc bsg_get_module_name {module_path} {

  regexp {[A-Za-z0-9_]+\.v} $module_path module_name

  return $module_name
}

set asic_hard_module_list [list]

foreach f $asic_hard_filelist {
  lappend asic_hard_module_list [bsg_get_module_name $f]
}

foreach f $SVERILOG_SOURCE_FILES {

  set asic_module_name [bsg_get_module_name $f]
  set idx [lsearch $asic_hard_module_list $asic_module_name]

  # replacement occurs here
  if {$idx == -1} {
    lappend tmp_list $f
  } else {
    lappend tmp_list [lindex $asic_hard_filelist $idx]
  }

}

set SVERILOG_SOURCE_FILES [concat $tmp_list $NEW_SVERILOG_SOURCE_FILES]
set DC_SOURCE_FILES [concat $SVERILOG_SOURCE_FILES $NETLIST_SOURCE_FILES]
