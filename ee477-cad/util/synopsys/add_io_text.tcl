####################################################################################################
# Description: The purpose of the script is to provide same automation as
# dbAddIOText command which was present in Astro.
#
# This script takes three inputs:
#   First input  --- layer name on which text has to created.
#   Second input --- height of text
#   Third input  --- type of text that has to be created on IO's.
#
# Third input can be one of three types:
#   1. cellInstName
#   2. netName
#   3. portName
#
# If cellInstName is given as third input then texts will be created with
# Instance names. If netName is given as third input then texts will be created
# with net names. If portName is given as third input then texts will be
# created with port names.
#
# Original Author: kapilr@synopsys.com
####################################################################################################
#
# Usage:
#   icc_shell> source add_io_text.tcl
#   icc_shell> add_io_text METAL1 5 cellInstName
#   icc_shell> add_io_text METAL1 5 portName
#
####################################################################################################

proc add_io_text_custom {io_cells layername text_string pin_bbox} {

  foreach_in_collection io_cell $io_cells {
    set cell_bbox [get_attribute $io_cell bbox]
    set cell_ll_x [lindex [lindex $cell_bbox 0] 0]
    set cell_ll_y [lindex [lindex $cell_bbox 0] 1]
    set cell_ur_x [lindex [lindex $cell_bbox 1] 0]
    set cell_ur_y [lindex [lindex $cell_bbox 1] 1]

    set pin_ll_x [lindex [lindex $pin_bbox 0] 0]
    set pin_ll_y [lindex [lindex $pin_bbox 0] 1]
    set pin_ur_x [lindex [lindex $pin_bbox 1] 0]
    set pin_ur_y [lindex [lindex $pin_bbox 1] 1]

    set text_height [expr [expr $pin_ur_y - $pin_ll_y] / 2]
    set offset [expr $text_height / 2]
    set orien [get_attribute [get_attribute $io_cell full_name] orientation]

    if {[string equal S $orien]} {
      set text_x [expr $cell_ur_x - $pin_ll_x]
      set text_y [expr [expr $cell_ur_y - $pin_ll_y] - $offset]
    } elseif {[string equal N $orien]} {
      set text_x [expr $cell_ll_x + $pin_ll_x]
      set text_y [expr [expr $cell_ll_y + $pin_ll_y] + $offset]
    } elseif {[string equal W $orien]} {
      set text_x [expr [expr $cell_ur_x - $pin_ll_y] - $offset]
      set text_y [expr $cell_ll_y + $pin_ll_x]
    } elseif {[string equal E $orien]} {
      set text_x [expr [expr $cell_ll_x + $pin_ll_y] + $offset]
      set text_y [expr $cell_ur_y - $pin_ll_x]
    }

    create_text -height $text_height -orient $orien -layer $layername -origin [list $text_x $text_y] $text_string
  }
}

proc add_io_text {layername text_height texttype} {

  # Power, filler and corner cells should not be included in io_cells.
  # If they are, check their cell properties.

  # STD --> added to filter out PVDD and PVSS pads. In tsmc180, the IO power
  # pads were not being instantiated as 'physical-only' cells therefore we
  # needed to filter them out here. This should not affect other process nodes
  # unless they have signal pads that start with PVDD or PVSS
  set io_cells [get_cells -hier -filter "is_io == TRUE && ref_name !~ PVDD* && ref_name !~ PVSS*"]

  foreach_in_collection cell $io_cells {
    set cell_box [get_attribute $cell bbox]
    set cell_ll_x [lindex [lindex $cell_box 0] 0]
    set cell_ll_y [lindex [lindex $cell_box 0] 1]
    set cell_ur_x [lindex [lindex $cell_box 1] 0]
    set cell_ur_y [lindex [lindex $cell_box 1] 1]

    if {[string equal cellInstName $texttype]} {
      set text_x [expr [expr $cell_ll_x + $cell_ur_x] / 2]
      set text_y [expr [expr $cell_ll_y + $cell_ur_y] / 2]
      if {[string equal S [get_attribute [get_attribute $cell full_name] orientation]]} {
        create_text -height $text_height -orient W -layer $layername -origin [list $text_x $text_y] [get_attribute $cell full_name]
      } elseif {[string equal N [get_attribute [get_attribute $cell full_name] orientation]]} {
        create_text -height $text_height -orient W -layer $layername -origin [list $text_x $text_y] [get_attribute $cell full_name]
      } else {
        create_text -height $text_height -layer $layername -origin [list $text_x $text_y] [get_attribute $cell full_name]
      }
    }

    if {[string equal netName $texttype]} {
      echo "Warning: Adding netName to an IO cell is not implemented yet."
    }

    if {[string equal portName $texttype]} {
      set design_ports [get_ports]
      foreach_in_collection port $design_ports {
        set cell_pins [get_pins -of [get_attribute $cell full_name]]
        set port_name [get_attribute $port full_name]
        # Find the cell pin (same name as port's name) to add text to.
        foreach_in_collection cell_pin $cell_pins {
          set pin_name [get_attribute -quiet [all_connected $cell_pin] full_name]
          # echo "  Processing $pin_name"
          if {[string equal $port_name $pin_name]} {
            set text_string $port_name
            set target_pin $cell_pin
            set target_pin_name [get_attribute -quiet $cell_pin full_name]
            echo "  Adding port name $text_string to cell pin $target_pin_name"
          }
        }
      }
      set pin_box [get_attribute $target_pin bbox]
      set pin_ll_x [lindex [lindex $pin_box 0] 0]
      set pin_ll_y [lindex [lindex $pin_box 0] 1]
      set pin_ur_x [lindex [lindex $pin_box 1] 0]
      set pin_ur_y [lindex [lindex $pin_box 1] 1]
      set text_x   [expr [expr $pin_ll_x + $pin_ur_x] / 2]
      set text_y   [expr [expr $pin_ll_y + $pin_ur_y] / 2]

      if {[string equal S [get_attribute [get_attribute $cell full_name] orientation]]} {
        create_text -height $text_height -orient W -layer $layername -origin [list $text_x $text_y] $text_string
      } elseif {[string equal N [get_attribute [get_attribute $cell full_name] orientation]]} {
        create_text -height $text_height -orient W -layer $layername -origin [list $text_x $text_y] $text_string
      } else {
        create_text -height $text_height -layer $layername -origin [list $text_x $text_y] $text_string
      }
    }
  }
}
