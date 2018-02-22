#-----------------------------------------------------------------------------
#  University of California, San Diego - Center for Dark Silicon
#-----------------------------------------------------------------------------
#  io_fp_lib.tcl
#
#  Purpose: Library for IO-floorplanning in ICC
#           - Place pads procedure (bond-pads/pads)
#           - Place bond pads procedure (just bond pads)
#           - Place corner
#           - Write xy coordinates (bond-pads/pads/macros)
#
#  Author: Luis Vega - vegaluisjose@gmail.com
#-----------------------------------------------------------------------------

#-----------------
# Common functions
#-----------------

proc remove_existing_cell {cell_ref_name cell_orientation} {
  set existing_cell [get_cells -quiet -all -hierarchical -filter "ref_name==$cell_ref_name && orientation==$cell_orientation"]
  if {$existing_cell !=""} {
    puts "Info: Removing pre-existing cell $cell_ref_name."
    remove_cell $existing_cell
  } else {
    puts "Info: Nothing to remove, $cell_ref_name not found"
  }
}

proc get_sort_pad_list {pad_orientation} {

  set pad_list ""
  set raw_pad_list [collection_to_list -name_only -no_braces [get_cells -all -hierarchical -filter "(mask_layout_type==io_pad || mask_layout_type==pad_filler) && orientation==$pad_orientation"]]
  foreach pad $raw_pad_list {
    if {$pad_orientation == "E" || $pad_orientation == "W"} {
      set pad_index [lindex [get_attribute [get_cells -all $pad] origin] 1]
    } elseif {$pad_orientation == "S" || $pad_orientation == "N"} {
      set pad_index [lindex [get_attribute [get_cells -all $pad] origin] 0]
    }
    lappend pad_list [list $pad $pad_index]
  }

  # Sort pad list by coordinates
  set sort_pad_list [lsort -real -index 1 $pad_list]

  return $sort_pad_list
}

proc get_total_pad_width {pad_list} {
  set total_width 0
  set i 0
  foreach pad $pad_list {
    set pad_name [lindex $pad 0]
    set pad_width [get_attribute [get_cells -all $pad_name] width]
    set total_width [expr $total_width + $pad_width]
  }

  return $total_width
}

proc side_to_orientation {side} {
  if {$side == "left"} {
    set orientation E
  } elseif {$side == "top"} {
    set orientation S
  } elseif {$side == "right"} {
    set orientation W
  } elseif {$side == "bottom"} {
    set orientation N
  }
  return $orientation
}

proc orientation_to_side {orientation} {
  if {$orientation == "E"} {
    set side "left"
  } elseif {$orientation == "S"} {
    set side "top"
  } elseif {$orientation == "W"} {
    set side "right"
  } elseif {$orientation == "N"} {
    set side "bottom"
  }
  return $side
}

#-------------------
# Place pad function
#-------------------

proc place_pad {args} {

  parse_proc_arguments -args $args pargs

  # Get side
  if {[info exists pargs(-side)]} {
    set side $pargs(-side)
    if {$side != "left" && $side != "top" && $side != "right" && $side != "bottom"} {
      puts "Error: Please specify a valid side <left, top, right, bottom>"
      return
    }
  } else {
    puts "Error: Please specify a side"
    return
  }

  # Get inline (inner) bond pad cell
  if {[info exists pargs(-inner_bond_pad_ref_name)]} {
    set inner_bond_pad_ref_name $pargs(-inner_bond_pad_ref_name)
    if {[get_physical_lib_cells $inner_bond_pad_ref_name] == "" } {
      puts "Error: You specified inline bond pad cell $inner_bond_pad_ref_name don't exist in physical library."
      return
    }
  } else {
    puts "Error: Please specify the inline bond pad ref_name."
    return
  }

  # Get outer bond pad cell
  if {[info exists pargs(-outer_bond_pad_ref_name)]} {
    set outer_bond_pad_ref_name $pargs(-outer_bond_pad_ref_name)
    if {[get_physical_lib_cells $outer_bond_pad_ref_name] == "" } {
      puts "Error: You specified outer bond pad cell $outer_bond_pad_ref_name don't exist in physical library."
      return
    }
  } else {
    puts "Error: Please specify the outer bond pad ref_name."
    return
  }

  set old_snap_state [set_object_snap_type -enabled false]
  suppress_message {HDU-104 HDUEDIT-104}

  set pad_orientation [side_to_orientation $side]

  # Inline bondpad size information
  set inner_bond_pad_bbox [get_attribute [get_physical_lib_cells $inner_bond_pad_ref_name] bbox]
  set inner_bond_pad_width  [expr [lindex $inner_bond_pad_bbox 1 0] - [lindex $inner_bond_pad_bbox 0 0]]
  set inner_bond_pad_height [expr [lindex $inner_bond_pad_bbox 1 1] - [lindex $inner_bond_pad_bbox 0 1]]

  # Stagger bondpad size information
  set outer_bond_pad_bbox [get_attribute [get_physical_lib_cells $outer_bond_pad_ref_name] bbox]
  set outer_bond_pad_width  [expr [lindex $outer_bond_pad_bbox 1 0] - [lindex $outer_bond_pad_bbox 0 0]]
  set outer_bond_pad_height [expr [lindex $outer_bond_pad_bbox 1 1] - [lindex $outer_bond_pad_bbox 0 1]]

  # Maximum bondpad height
  set max_bond_pad_height $outer_bond_pad_height

  # Get die area and coordinates
  set die_bbox [get_attribute [get_die_area] bbox]
  set die_LL_X [lindex $die_bbox 0 0]
  set die_LL_Y [lindex $die_bbox 0 1]
  set die_UR_X [lindex $die_bbox 1 0]
  set die_UR_Y [lindex $die_bbox 1 1]

  # Get core area and coordinates
  set core_bbox [get_attribute [get_core_area] bbox]
  set core_LL_X [lindex $core_bbox 0 0]
  set core_LL_Y [lindex $core_bbox 0 1]
  set core_UR_X [lindex $core_bbox 1 0]
  set core_UR_Y [lindex $core_bbox 1 1]

  set sort_pad_list [get_sort_pad_list $pad_orientation]
  set number_of_pad [llength $sort_pad_list]

  # Remove existing bond pads
  remove_existing_cell $inner_bond_pad_ref_name $pad_orientation
  remove_existing_cell $outer_bond_pad_ref_name $pad_orientation

  # Iterate over pad list to place and create pads and bond-pads
  set i 0
  set power_pattern "^VZZ.*\|^V33.*\|^VSS.*\|^VDD.*"
  foreach pad $sort_pad_list {

    # Get pad name
    set pad_name [lindex $pad 0]
    if {[regexp $power_pattern $pad_name]} {
      set is_outer "true"
    } else {
      set is_outer "false"
    }
    set bond_pad_name ""

    # Get pad size
    set pad_width [get_attribute [get_cells -all $pad_name] width]
    set pad_height [get_attribute [get_cells -all $pad_name] height]

    # Set pitch as pad width
    set pitch $pad_width

    # Initial coordinates for pad
    if {$i == 0} {
      set total_pad_width [get_total_pad_width $sort_pad_list]
      if {$side == "left"} {
        set pad_LL_X $die_LL_X
        set pad_LL_Y [expr $core_LL_Y + ($core_UR_Y*1000 - $core_LL_Y*1000)/2000 - $total_pad_width/2]
      } elseif {$side == "right"} {
        set pad_LL_X [expr $die_UR_X - $pad_height]
        set pad_LL_Y [expr $core_LL_Y + ($core_UR_Y*1000 - $core_LL_Y*1000)/2000 - $total_pad_width/2]
      } elseif {$side == "top"} {
        set pad_LL_X [expr $core_LL_X + ($core_UR_X*1000 - $core_LL_X*1000)/2000 - $total_pad_width/2]
        set pad_LL_Y [expr $die_UR_Y - $pad_height]
      } elseif {$side == "bottom"} {
        set pad_LL_X [expr $core_LL_X + ($core_UR_X*1000 - $core_LL_X*1000)/2000 - $total_pad_width/2]
        set pad_LL_Y $die_LL_Y
      }
    }

    # Placing pad
    move_objects -to [list $pad_LL_X $pad_LL_Y] [get_cells -all $pad_name]

    # New coordinates for bond pads
    if {$is_outer == "true"} {
      if {$side == "left"} {
        set bond_pad_LL_X [expr $pad_LL_X - $outer_bond_pad_height]
        set bond_pad_LL_Y $pad_LL_Y
      } elseif {$side == "bottom"} {
        set bond_pad_LL_X $pad_LL_X
        set bond_pad_LL_Y [expr $pad_LL_Y - $outer_bond_pad_height]
      }
    } else {
      if {$side == "left"} {
        set bond_pad_LL_X [expr $pad_LL_X - $inner_bond_pad_height]
        set bond_pad_LL_Y $pad_LL_Y
      } elseif {$side == "bottom"} {
        set bond_pad_LL_X $pad_LL_X
        set bond_pad_LL_Y [expr $pad_LL_Y - $inner_bond_pad_height]
      }
    }

    if {$side == "right"} {
      set bond_pad_LL_X [expr $pad_LL_X + $pad_height]
      set bond_pad_LL_Y $pad_LL_Y
    } elseif {$side == "top"} {
      set bond_pad_LL_X $pad_LL_X
      set bond_pad_LL_Y [expr $pad_LL_Y + $pad_height]
    }

    # Creating/placing bond-pad
    set pad_type [get_attribute [get_cells -all $pad_name] mask_layout_type]
    if {$pad_type == "io_pad"} {
      if {$is_outer == "true"} {
        append bond_pad_name "bpo_" $pad_name
        create_cell $bond_pad_name $outer_bond_pad_ref_name
      } else {
        append bond_pad_name "bpi_" $pad_name
        create_cell $bond_pad_name $inner_bond_pad_ref_name
      }
      set_attribute -quiet $bond_pad_name orientation $pad_orientation
      move_objects -to [list $bond_pad_LL_X $bond_pad_LL_Y] [get_cells -all $bond_pad_name]
    }

    # New coordinates for pads
    if {$side == "left" || $side == "right"} {
      set pad_LL_Y [expr $pad_LL_Y + $pitch]
    } elseif {$side == "top" || $side == "bottom"} {
      set pad_LL_X [expr $pad_LL_X + $pitch]
    }
    set i [expr $i + 1]
  }

  unsuppress_message {HDU-104 HDUEDIT-104}
  set_object_snap_type -enabled $old_snap_state
}

define_proc_attributes place_pad \
  -info "place_pad - place and create pads and bond-pads" \
  -define_args {
  {-side  "die side <left | top | right | bottom>" side string required}
  {-inner_bond_pad_ref_name "inner bond pad cell, i.e. PADIZ40" inner_bond_pad_ref_name string required}
  {-outer_bond_pad_ref_name "outer bond pad cell, i.e. PADOZ40" outer_bond_pad_ref_name string required}
}

#------------------------
# Place bond pad function
#------------------------

proc place_bond_pad {args} {

  parse_proc_arguments -args $args pargs

  # Get side
  if {[info exists pargs(-side)]} {
    set side $pargs(-side)
    if {$side != "left" && $side != "top" && $side != "right" && $side != "bottom"} {
      puts "Error: Please specify a valid side <left, top, right, bottom>"
      return
    }
  } else {
    puts "Error: Please specify a side"
    return
  }

  # Get inline (inner) bond pad cell
  if {[info exists pargs(-inner_bond_pad_ref_name)]} {
    set inner_bond_pad_ref_name $pargs(-inner_bond_pad_ref_name)
    if {[get_physical_lib_cells $inner_bond_pad_ref_name] == "" } {
      puts "Error: You specified inline bond pad cell $inner_bond_pad_ref_name don't exist in physical library."
      return
    }
  } else {
    puts "Error: Please specify the inline bond pad ref_name."
    return
  }

  # Get outer bond pad cell
  if {[info exists pargs(-outer_bond_pad_ref_name)]} {
    set outer_bond_pad_ref_name $pargs(-outer_bond_pad_ref_name)
    if {[get_physical_lib_cells $outer_bond_pad_ref_name] == "" } {
      puts "Error: You specified outer bond pad cell $outer_bond_pad_ref_name don't exist in physical library."
      return
    }
  } else {
    puts "Error: Please specify the outer bond pad ref_name."
    return
  }

  # Get exclude bond pad cells
  if {[info exists pargs(-exclude_cells)]} {
    set exclude_cells $pargs(-exclude_cells)
  } else {
    set exclude_cells [list]
  }

  # Disable snap and save previous state to restore later
  set old_snap_state [set_object_snap_type -enabled false]
  suppress_message {HDU-104 HDUEDIT-104}

  # Open file for bond pad glass coordinates
  set fid [open "bp_glass_coor.$side.csv" w]
  puts $fid "#Pad Name,#BBox LLX,#BBox LLY,#BBox URX,#BBox URY,#Center X,#Center Y"

  # Get the pad orientation based on which side it is on
  set pad_orientation [side_to_orientation $side]

  # Inline bondpad size information
  set inner_bond_pad_bbox [get_attribute [get_physical_lib_cells $inner_bond_pad_ref_name] bbox]
  set inner_bond_pad_width  [expr [lindex $inner_bond_pad_bbox 1 0] - [lindex $inner_bond_pad_bbox 0 0]]
  set inner_bond_pad_height [expr [lindex $inner_bond_pad_bbox 1 1] - [lindex $inner_bond_pad_bbox 0 1]]

  # Stagger bondpad size information
  set outer_bond_pad_bbox [get_attribute [get_physical_lib_cells $outer_bond_pad_ref_name] bbox]
  set outer_bond_pad_width  [expr [lindex $outer_bond_pad_bbox 1 0] - [lindex $outer_bond_pad_bbox 0 0]]
  set outer_bond_pad_height [expr [lindex $outer_bond_pad_bbox 1 1] - [lindex $outer_bond_pad_bbox 0 1]]

  # Get a sorted pad list
  set sort_pad_list [get_sort_pad_list $pad_orientation]

  # Remove existing bond pads
  remove_existing_cell $inner_bond_pad_ref_name $pad_orientation
  remove_existing_cell $outer_bond_pad_ref_name $pad_orientation

  # Regex pattern for power pads (outer pads...)
  set power_pattern "^VZZ.*\|^V33.*\|^VSS.*\|^VDD.*\|^VCC.*"

  # Iterate over pad list to place and create pads and bond-pads
  foreach pad $sort_pad_list {

    # Get pad name
    set pad_name [lindex $pad 0]
    
    # Make sure it is not part of the exclude cell list
    if {[lsearch $exclude_cells [get_attribute [get_cells -all $pad_name] full_name]] == -1} {

      # All power pads are outer pads
      if {[regexp $power_pattern $pad_name]} {
        set is_outer "true"
      } else {
        set is_outer "false"
      }

      # Get pad cell bbox
      set pad_bbox [get_attribute [get_cells -all $pad_name] bbox]
      set pad_LL_X [lindex $pad_bbox 0 0]
      set pad_LL_Y [lindex $pad_bbox 0 1]
      set pad_UR_X [lindex $pad_bbox 1 0]
      set pad_UR_Y [lindex $pad_bbox 1 1]

      # Get bond pad coordinates
      if {$side == "left"} {
        if {$is_outer == "true"} {
          set bond_pad_LL_X [expr $pad_LL_X - $outer_bond_pad_height]
        } else {
          set bond_pad_LL_X [expr $pad_LL_X - $inner_bond_pad_height]
        }
        set bond_pad_LL_Y $pad_LL_Y
      } elseif {$side == "top"} {
        set bond_pad_LL_X $pad_LL_X
        set bond_pad_LL_Y $pad_UR_Y
      } elseif {$side == "right"} {
        set bond_pad_LL_X $pad_UR_X
        set bond_pad_LL_Y $pad_LL_Y
      } elseif {$side == "bottom"} {
        set bond_pad_LL_X $pad_LL_X
        if {$is_outer == "true"} {
          set bond_pad_LL_Y [expr $pad_LL_Y - $outer_bond_pad_height]
        } else {
          set bond_pad_LL_Y [expr $pad_LL_Y - $inner_bond_pad_height]
        }
      }

      # Create and place bond-pad
      set pad_type [get_attribute [get_cells -all $pad_name] mask_layout_type]
      if {$pad_type == "io_pad"} {
        if {$is_outer == "true"} {
          set bond_pad_name "bpo_$pad_name"
          create_cell $bond_pad_name $outer_bond_pad_ref_name
        } else {
          set bond_pad_name "bpi_$pad_name"
          create_cell $bond_pad_name $inner_bond_pad_ref_name
        }
        set_attribute -quiet $bond_pad_name orientation $pad_orientation
        move_objects -to [list $bond_pad_LL_X $bond_pad_LL_Y] [get_cells -all $bond_pad_name]
      }

      # Get the new bond pad bbox
      set bp_bbox [get_attribute $bond_pad_name bbox]
      set bp_llx [lindex $bp_bbox 0 0]
      set bp_lly [lindex $bp_bbox 0 1]
      set bp_urx [lindex $bp_bbox 1 0]
      set bp_ury [lindex $bp_bbox 1 1]

      # Glass constnats for tsmc180 (based on BOTTOM LL orientation -- same for inner and outer pads)
      set glass_relative_llx -11.5
      set glass_relative_lly 2
      set glass_relative_urx 41.5
      set glass_relative_ury 68

      # Calc glass coordinates
      if {$side == "left"} {
        set glass_llx [expr $bp_llx + $glass_relative_lly]
        set glass_lly [expr $bp_ury - $glass_relative_urx]
        set glass_urx [expr $bp_llx + $glass_relative_ury]
        set glass_ury [expr $bp_ury - $glass_relative_llx]
      } elseif {$side == "top"} {
        set glass_llx [expr $bp_urx - $glass_relative_urx]
        set glass_lly [expr $bp_ury - $glass_relative_ury]
        set glass_urx [expr $bp_urx - $glass_relative_llx]
        set glass_ury [expr $bp_ury - $glass_relative_lly]
      } elseif {$side == "right"} {
        set glass_llx [expr $bp_urx - $glass_relative_ury]
        set glass_lly [expr $bp_lly + $glass_relative_llx]
        set glass_urx [expr $bp_urx - $glass_relative_lly]
        set glass_ury [expr $bp_lly + $glass_relative_urx]
      } elseif {$side == "bottom"} {
        set glass_llx [expr $bp_llx + $glass_relative_llx]
        set glass_lly [expr $bp_lly + $glass_relative_lly]
        set glass_urx [expr $bp_llx + $glass_relative_urx]
        set glass_ury [expr $bp_lly + $glass_relative_ury]
      }

      # Calc center glass coordinates for dump file
      set glass_cx  [expr ($glass_urx + $glass_llx) / 2.0]
      set glass_cy  [expr ($glass_ury + $glass_lly) / 2.0]

      # Output glass coordinates for the bond pad
      puts $fid "$pad_name,$glass_llx,$glass_lly,$glass_urx,$glass_ury,$glass_cx,$glass_cy"
    }
  }

  # Restore previous snap state
  unsuppress_message {HDU-104 HDUEDIT-104}
  set_object_snap_type -enabled $old_snap_state
  
  # Close glass coordinate file
  close $fid

}

define_proc_attributes place_bond_pad \
  -info "place_bond_pad - place and create bond-pads" \
  -define_args {
  {-side  "die side <left | top | right | bottom>" side string required}
  {-inner_bond_pad_ref_name "inner bond pad cell, i.e. PADIZ40" inner_bond_pad_ref_name string required}
  {-outer_bond_pad_ref_name "outer bond pad cell, i.e. PADOZ40" outer_bond_pad_ref_name string required}
  {-exclude_cells "list of cells that do not need bond pads" exclude_cells string optional}
}

#-----------------------
# Place corner functions
#-----------------------

proc place_corner {} {
  set old_snap_state [set_object_snap_type -enabled false]

  set one_left_pad [lindex [collection_to_list -name_only -no_braces [get_cells -all -hierarchical -filter "mask_layout_type==io_pad && orientation==E"]] 0]
  set one_top_pad [lindex [collection_to_list -name_only -no_braces [get_cells -all -hierarchical -filter "mask_layout_type==io_pad && orientation==S"]] 0]
  set one_right_pad [lindex [collection_to_list -name_only -no_braces [get_cells -all -hierarchical -filter "mask_layout_type==io_pad && orientation==W"]] 0]
  set one_bottom_pad [lindex [collection_to_list -name_only -no_braces [get_cells -all -hierarchical -filter "mask_layout_type==io_pad && orientation==N"]] 0]

  set corner_UL_X [lindex [get_attribute [get_cells -all $one_left_pad] bbox] 0 0]
  set corner_UL_Y [lindex [get_attribute [get_cells -all $one_top_pad] bbox] 0 1]
  set corner_UR_X [lindex [get_attribute [get_cells -all $one_right_pad] bbox] 0 0]
  set corner_LR_Y [lindex [get_attribute [get_cells -all $one_bottom_pad] bbox] 0 1]

  move_objects -to [list $corner_UL_X $corner_UL_Y] [get_cells -all -hierarchical -filter "mask_layout_type==corner_pad && orientation==E"]
  move_objects -to [list $corner_UR_X $corner_UL_Y] [get_cells -all -hierarchical -filter "mask_layout_type==corner_pad && orientation==S"]
  move_objects -to [list $corner_UR_X $corner_LR_Y] [get_cells -all -hierarchical -filter "mask_layout_type==corner_pad && orientation==W"]
  move_objects -to [list $corner_UL_X $corner_LR_Y] [get_cells -all -hierarchical -filter "mask_layout_type==corner_pad && orientation==N"]

  set_object_snap_type -enabled $old_snap_state
}

#-------------------
# Write xy functions
#-------------------

proc get_area_xy {area_name} {
  set area_bbox [get_attribute [get_$area_name] bbox]
  # Empty line
  set line ""
  # area name
  append line $area_name
  # LL_X and LL_Y
  append line "," [lindex $area_bbox 0 0] "," [lindex $area_bbox 0 1]
  # UR_X and UR_Y
  append line "," [lindex $area_bbox 1 0] "," [lindex $area_bbox 1 1]
  return $line
}

proc get_cell_info {cell_name} {
  set cell_bbox [get_attribute [get_cells -all $cell_name] bbox]
  set cell_side [orientation_to_side [get_attribute [get_cells -all $cell_name] orientation]]
  # Empty line
  set line ""
  # cell name
  append line $cell_name
  # LL_X and LL_Y
  append line "," [lindex $cell_bbox 0 0] "," [lindex $cell_bbox 0 1]
  # UR_X and UR_Y
  append line "," [lindex $cell_bbox 1 0] "," [lindex $cell_bbox 1 1]
  # cell side
  append line "," $cell_side
  return $line
}

proc write_xy {args} {

  parse_proc_arguments -args $args pargs

  # Get output file
  if {[info exists pargs(-output)]} {
    set io_file $pargs(-output)
    if {$io_file == ""} {
      puts "Error: Please specify an output file"
      return
    }
  } else {
    puts "Error: Please specify an output file"
    return
  }

  # Check if pads are included
  if {[info exists pargs(-include_pad)]} {
    set include_pad $pargs(-include_pad)
    if {$include_pad != "true" && $include_pad != "false"} {
      puts "Error: Include pad option accepts true or false only"
      return
    }
  } else {
    set include_pad "false"
  }

  # Check if macros are included
  if {[info exists pargs(-include_macro)]} {
    set include_macro $pargs(-include_macro)
    if {$include_macro != "true" && $include_macro != "false"} {
      puts "Error: Include macro option accepts true or false only"
      return
    }
  } else {
    set include_macro "false"
  }

  set file_id [open $io_file "w"]
  puts $file_id [get_area_xy "die_area"]
  puts $file_id [get_area_xy "core_area"]

  if {$include_pad == "true" && $include_macro == "true"} {
    set cell_list [collection_to_list -name_only -no_braces [get_cells -all -hierarchical -filter "mask_layout_type==io_pad || mask_layout_type==pad_filler || mask_layout_type==corner_pad || mask_layout_type==macro"]]
  } elseif {$include_pad == "false" && $include_macro == "true"} {
    set cell_list [collection_to_list -name_only -no_braces [get_cells -all -hierarchical -filter "mask_layout_type==macro"]]
  } elseif {$include_pad == "true" && $include_macro == "false"} {
    set cell_list [collection_to_list -name_only -no_braces [get_cells -all -hierarchical -filter "mask_layout_type==io_pad || mask_layout_type==pad_filler || mask_layout_type==corner_pad"]]
    append cell_list " "
    append cell_list [collection_to_list -name_only -no_braces [get_cells -all -hierarchical -filter "mask_layout_type==flip_chip_pad"]]
  } else {
    set cell_list [collection_to_list -name_only -no_braces [get_cells -all -hierarchical -filter "mask_layout_type==flip_chip_pad"]]
  }

  foreach cell $cell_list {
    puts $file_id [get_cell_info $cell]
  }
  close $file_id
}

define_proc_attributes write_xy \
  -info "writes an output file with io coordinates" \
  -define_args {
  {-output  "output file" output string required}
  {-include_pad "true or false option, false is default value" include_pads string optional}
  {-include_macro "true or false option, false is default value" include_macro string optional}
}


#-----------------
# Place pad filler
#-----------------

proc get_sort_pad_filler_list {pad_orientation} {

  set pad_list ""
  set raw_pad_list [collection_to_list -name_only -no_braces [get_cells -all -hierarchical -filter "(mask_layout_type==io_pad || mask_layout_type==pad_filler) && orientation==$pad_orientation"]]
  foreach pad $raw_pad_list {
    if {$pad_orientation == "E" || $pad_orientation == "W"} {
      set pad_index [lindex [get_attribute [get_cells -all $pad] origin] 1]
    } elseif {$pad_orientation == "S" || $pad_orientation == "N"} {
      set pad_index [lindex [get_attribute [get_cells -all $pad] origin] 0]
    }
    lappend pad_list [list $pad $pad_index]
  }

  # Sort pad list by coordinates
  set sort_pad_list [lsort -real -index 1 $pad_list]

  return $sort_pad_list
}

proc get_upper_point {cell_name orientation} {
  if {$orientation == "E" || $orientation == "W"} {
    return [lindex [get_attribute [get_cells -all $cell_name] bbox] 1 1]
  } else {
    return [lindex [get_attribute [get_cells -all $cell_name] bbox] 1 0]
  }
}

proc get_lower_point {cell_name orientation} {
  if {$orientation == "E" || $orientation == "W"} {
    return [lindex [get_attribute [get_cells -all $cell_name] bbox] 0 1]
  } else {
    return [lindex [get_attribute [get_cells -all $cell_name] bbox] 0 0]
  }
}

proc check_pad_alignment {pad_1_name pad_2_name pad_orientation} {
  if {$pad_orientation == "E" || $pad_orientation == "W"} {
    set p1 [lindex [get_attribute [get_cells -all $pad_1_name] bbox] 0 0]
    set p2 [lindex [get_attribute [get_cells -all $pad_2_name] bbox] 0 0]
  } else {
    set p1 [lindex [get_attribute [get_cells -all $pad_1_name] bbox] 0 1]
    set p2 [lindex [get_attribute [get_cells -all $pad_2_name] bbox] 0 1]
  }
  if {$p1 == $p2} {
    return 1
  } else {
    return 0
  }
}

proc create_and_move_pad_filler {pad_filler_name pad_filler_ref_name pad_orientation lower_pad_name new_filler_coordinate} {
  create_cell $pad_filler_name $pad_filler_ref_name
  set_attribute -quiet $pad_filler_name orientation $pad_orientation
  if {$pad_orientation == "E" || $pad_orientation == "W"} {
    set x [lindex [get_attribute [get_cells -all $lower_pad_name] bbox] 0 0]
    move_objects -to [list $x $new_filler_coordinate] [get_cells -all $pad_filler_name]
  } else {
    set y [lindex [get_attribute [get_cells -all $lower_pad_name] bbox] 0 1]
    move_objects -to [list $new_filler_coordinate $y] [get_cells -all $pad_filler_name]
  }
}

proc place_pad_filler {args} {

  parse_proc_arguments -args $args pargs

  # Get side
  if {[info exists pargs(-side)]} {
    set side $pargs(-side)
    if {$side != "left" && $side != "top" && $side != "right" && $side != "bottom"} {
      puts "Error: Please specify a valid side <left, top, right, bottom>"
      return
    }
  } else {
    puts "Error: Please specify a side"
    return
  }

  # Get pad filler cell
  if {[info exists pargs(-pad_filler_ref_name)]} {
    set pad_filler_ref_name $pargs(-pad_filler_ref_name)
    if {[get_physical_lib_cells $pad_filler_ref_name] == "" } {
      puts "Error: You specified a pad filler $pad_filler_ref_name that don't exist in physical library."
      return
    }
  } else {
    puts "Error: Please specify a pad filler cell"
    return
  }

  set preffix ${side}_pad_filler_${pad_filler_ref_name}

  create_cell dummy_cell $pad_filler_ref_name
  set pad_filler_width [get_attribute [get_cells -all dummy_cell] width]
  remove_cell dummy_cell

  set pad_orientation [side_to_orientation $side]

  # Select corners according to selected side
  if {$pad_orientation == "E"} {
    set first_corner_name [get_attribute [get_cells -all -hierarchical -filter "mask_layout_type==corner_pad && orientation==N"] name]
    set last_corner_name [get_attribute [get_cells -all -hierarchical -filter "mask_layout_type==corner_pad && orientation==E"] name]
  } elseif {$pad_orientation == "S"} {
    set first_corner_name [get_attribute [get_cells -all -hierarchical -filter "mask_layout_type==corner_pad && orientation==E"] name]
    set last_corner_name [get_attribute [get_cells -all -hierarchical -filter "mask_layout_type==corner_pad && orientation==S"] name]
  } elseif {$pad_orientation == "W"} {
    set first_corner_name [get_attribute [get_cells -all -hierarchical -filter "mask_layout_type==corner_pad && orientation==W"] name]
    set last_corner_name [get_attribute [get_cells -all -hierarchical -filter "mask_layout_type==corner_pad && orientation==S"] name]
  } else {
    set first_corner_name [get_attribute [get_cells -all -hierarchical -filter "mask_layout_type==corner_pad && orientation==N"] name]
    set last_corner_name [get_attribute [get_cells -all -hierarchical -filter "mask_layout_type==corner_pad && orientation==W"] name]
  }

  # Get pad list and append a corner to the begin/end of the list
  set pad_list [get_sort_pad_filler_list $pad_orientation]
  set pad_list [linsert $pad_list 0 [list $first_corner_name 0]]
  set pad_list [linsert $pad_list end [list $last_corner_name 0]]

  set number_of_pad [llength $pad_list]

  set old_snap_state [set_object_snap_type -enabled false]
  suppress_message {HDU-104 HDUEDIT-104}

  set number_of_placed_pad_fillers 0
  set number_of_gaps 0
  for {set i 0} {$i<[expr $number_of_pad - 1]} {incr i} {
      set lower_pad_name [lindex [lindex $pad_list $i] 0]
      set upper_pad_name [lindex [lindex $pad_list [expr $i + 1]] 0]
      if {![check_pad_alignment $lower_pad_name $upper_pad_name $pad_orientation]} {
        puts "Error: $lower_pad_name and $upper_pad_name are not aligned"
        return
      }
      set p1 [get_upper_point $lower_pad_name $pad_orientation]
      set p2 [get_lower_point $upper_pad_name $pad_orientation]
      set gap [expr $p2*1000 - $p1*1000]
      set gap [expr $gap/1000]
      while {$gap >= $pad_filler_width} {
        set pad_filler_name ${preffix}_${number_of_placed_pad_fillers}
        create_and_move_pad_filler $pad_filler_name $pad_filler_ref_name $pad_orientation $lower_pad_name $p1
        set p1 [get_upper_point $pad_filler_name $pad_orientation]
        set gap [expr $p2*1000 - $p1*1000]
        set gap [expr $gap/1000]
        set number_of_placed_pad_fillers [expr $number_of_placed_pad_fillers + 1]
      }
      if {$gap > 0} {
        puts "Warning: There is a gap of $gap between $lower_pad_name and $upper_pad_name"
        set number_of_gaps [expr $number_of_gaps + 1]
      }
  }

  unsuppress_message {HDU-104 HDUEDIT-104}
  set_object_snap_type -enabled $old_snap_state
  puts "Info: Number of $pad_filler_ref_name added: $number_of_placed_pad_fillers"
  puts "Info: Number of remaining gaps on $side-side after $pad_filler_ref_name placement: $number_of_gaps"
}

define_proc_attributes place_pad_filler \
  -info "place_pad_filler - place and create pad filler" \
  -define_args {
  {-side  "side <left | top | right | bottom>" side string required}
  {-pad_filler_ref_name "Pad filler cell name, i.e. PFEED8Z" pad_filler_ref_name string required}
}
