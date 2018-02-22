#-----------------------------------------------------------------------------
#  University of California, San Diego
#-----------------------------------------------------------------------------
#  get_floating_shapes.tcl
#
#  Purpose: Find and return floating shapes in layout. Floating shapes are net
#           segments that are not connected to any other shapes, vias or pins.
#
#           Usually there are some floating power/ground pieces caused by power
#           delivery network changes. They are considered as errors by
#           "verify_pg_nets" command, and long floating pieces may cause DRC
#           violations on nearby signal routes. This script and function can
#           find such floating shapes in layout and return as a collection.
#
#-----------------------------------------------------------------------------

proc get_floating_shapes {args} {

  parse_proc_arguments -args $args pargs

  # get all shapes within die area

  if {[info exists pargs(-net_type)]} {
    set net_type $pargs(-net_type)
    set all_shapes {}
    if {$net_type != "All" && $net_type != "Power" && $net_type != "Ground" && $net_type != "Clock" && $net_type != "Signal"} {
      puts "Error: The net_type option only accepts All | Power | Ground | Clock | Signal."
      return {}
    } else {
      if {$net_type != "All"} {
        append_to_collection all_shapes [get_net_shapes -quiet -within [get_attribute [get_die_area] bbox] -filter "net_type==$net_type"]
      } else {
        # Get all types of floating shapes
        append_to_collection all_shapes [get_net_shapes -quiet -within [get_attribute [get_die_area] bbox]]
      }
    }
  }

  set floating_shapes {}

  set index 0
  puts "Will check [sizeof_collection $all_shapes] \"$net_type\" net shapes for floating ones."
  fconfigure stdout -buffering none
  foreach_in_collection shape $all_shapes {
      # dont slow down with print statements
      if {[expr $index & 255] == 0} {
          puts -nonewline "  Checking net shape #$index of [sizeof_collection $all_shapes]\r"
      }

    # Collections of objects that are electrically connected to the current shape
    set connected_pins   {}
    set connected_shapes {}
    set connected_vias   {}

    # Shape identifications
    set shape_bbox      [get_attribute $shape bbox]
    set shape_layer     [get_attribute $shape layer]

    # Get connected shapes: on the same metal layer, either -within or -intersert
    # NOTE: -within does NOT include the $shape itself
    append_to_collection connected_shapes [get_net_shapes -quiet -within    $shape_bbox -filter "layer==$shape_layer"]
    # NOTE: -intersect DOES include the $shape itself
    append_to_collection connected_shapes [get_net_shapes -quiet -intersect $shape_bbox -filter "layer==$shape_layer"]
    # Remove the $shape itself from collection
    set connected_shapes [remove_from_collection $connected_shapes $shape]

    if {[sizeof_collection $connected_shapes] > 0} { incr index; continue; }

    # Get connected vias
    append_to_collection connected_vias [get_vias -quiet -within    $shape_bbox -filter "lower_layer==$shape_layer || upper_layer==$shape_layer"]
    append_to_collection connected_vias [get_vias -quiet -intersect $shape_bbox -filter "lower_layer==$shape_layer || upper_layer==$shape_layer"]

    if {[sizeof_collection $connected_vias] > 0} { incr index; continue; }

    # Get connected pins
    append_to_collection connected_pins [get_pin_shapes -quiet -within    $shape_bbox -filter "layer==$shape_layer"]
    append_to_collection connected_pins [get_pin_shapes -quiet -intersect $shape_bbox -filter "layer==$shape_layer"]

    if {[sizeof_collection $connected_pins] > 0} { incr index; continue; }

    # No shapes, vias, or pins are connected to the $shape.
    append_to_collection floating_shapes $shape
  }

  puts "Totally checked shapes of \"$net_type\" net type: [sizeof_collection $all_shapes]"
  puts "Number of floating shapes of \"$net_type\" net type: [sizeof_collection $floating_shapes]"

  return $floating_shapes
}

define_proc_attributes get_floating_shapes  \
  -info "get_floating_shapes - find and return floating shapes in layout." \
  -define_args {
    {-net_type "the net_type of shapes" "All | Power | Ground | Clock | Signal" string required}
  }
