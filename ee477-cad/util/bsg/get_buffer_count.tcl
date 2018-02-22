#-----------------------------------------------------------------------------
#  University of California, San Diego
#-----------------------------------------------------------------------------
#  get_buffer_count.tcl
#
#  Purpose: Get the types of buffers/inverters used to fix the setup or hold
#           violations in the current design, how many times each
#           buffer/inverter cell is used, and the instance names that
#           correspond to each buffer/inverter type.
#
#  Remarks: This function is inspired by the SolvNet Article 1868029.
#           https://solvnet.synopsys.com/retrieve/1868029.html
#           Scripts to Report the Inverter and Buffer Count and the
#           Corresponding Instance Names Used to Fix Setup and Hold Violations
#           in a Design
#
#           Requires IC Compiler Version >= H-2013.03 to use -fix option.
#
#-----------------------------------------------------------------------------

proc get_buffer_count {args} {

  parse_proc_arguments -args $args pargs

  if {[info exists pargs(-type)]} {
    set type $pargs(-type)
    if {$type != "buf" && $type != "inv"} {
      puts "Error: A -type value must be either \"buf\" or \"inv\"."
      return
    }
  } else {
    set type "buf"
  }

  if {[info exists pargs(-fix)]} {
    set fix $pargs(-fix)
    if {$fix != "setup" && $fix != "hold"} {
      puts "Error: A -fix value must be either \"setup\" or \"hold\"."
      return
    }
  } else {
    set fix "none"
  }

  if {$type == "buf"} {
    set buffers [get_buffers]
    puts "\nQuerying buffers in current design:\n"
  } else {
    set buffers [get_buffers -inverter]
    puts "\nQuerying inverters in current design:\n"
  }

  set total_cell_count 0
  foreach_in_collection cell $buffers {
    set cell_name [get_attribute $cell name]
    puts "Reference Buffer $cell_name"
    if {$fix != "none"} {
      set flat_cells [get_flat_cells -filter "optimization_stage==$fix && ref_name==$cell_name"]
    } else {
      set flat_cells [get_flat_cells -filter "ref_name==$cell_name"]
    }
    set cell_count [sizeof_collection $flat_cells]
    if {$fix != "none"} {
      puts "Number of $cell_name cells used to fix $fix violation in the design = $cell_count."
    } else {
      puts "Number of $cell_name cells used in the design = $cell_count."
    }
    query_objects $cell
    set total_cell_count [expr $total_cell_count + $cell_count]
  }

  if {$type == "buf"} {
    puts "\nTotal buffer count in the design = $total_cell_count.\n"
  } else {
    puts "\nTotal inverter count in the design = $total_cell_count.\n"
  }
}

define_proc_attributes get_buffer_count \
  -info "get_buffer_count - get the buffers/inverters used to fix the setup or hold violations in the current design." \
  -define_args {
    {-fix "the type of timing violations to be fixed" "setup | hold" string optional}
    {-type "specify the inserted cell type" "buf | inv" string optional}
  }
