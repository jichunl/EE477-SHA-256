# The magnet_place_dist procedure finds the distance between a macro pin and
# its connected standard cell pin before and after magnet cell placement is
# performed.
#
# Note:
#   Make sure that a macro is selected before you run the magnet_place_dist
#   procedure
#
proc magnet_place_dist { } {
  if {[sizeof_collection [get_selection]] == 1} {
    set pns_clcn [get_pins -of_objects [collection_to_list -name_only -no_braces [get_selection]]]
    puts "###############################################################################################"
    echo "The macro pin collection is shown below:"
    query_objects $pns_clcn

    puts "###############################################################################################"
    echo "Select and enter a macro pin from the above collection:"
    set mac_pin [gets stdin]

    set bbox1 [split "[get_attr [get_pin $mac_pin] bbox]" "{ }"]
    set mx [lindex $bbox1 5]
    set my [lindex $bbox1 2]
    set cl [get_pins -of_objects [collection_to_list -name_only -no_braces [get_nets -of_objects $mac_pin]]]
    puts "###############################################################################################"
    echo "The pin collection is as shown below:"
    query_objects $cl
    puts "Check if any of the above pins correspond to any magnet cells shown below"
    puts "###############################################################################################"
    set mag [get_magnet_cells $mac_pin]
    puts "The magnet cells for the macro pin $mac_pin are shown below:"
    query_objects $mag
    puts "###############################################################################################"
    echo "Select and enter a magnet standard cell pin from the above pin collection. If there are no magnet standard cell pins, press ENTER."
    set cell_pin [gets stdin]
    if {$cell_pin != ""} {
      set bbox2 [split "[get_attr [get_pin $cell_pin] bbox]" "{ }"]
      set sx [lindex $bbox2 1]
      set sy [lindex $bbox2 2]
      set distance_b [expr {sqrt ([expr {($mx - $sx) * ($mx - $sx)} + {($my - $sy) * ($my - $sy)}])}]
      puts "#######################################################################################"
      puts "Distance between the macro pin and the standard cell pin before magnet placement is $distance_b microns"
      magnet_placement -mark_soft_fixed [get_pins $mac_pin] -logical_level 1
      set bbox2_af_mg_pl [split "[get_attr [get_pin $cell_pin] bbox]" "{ }"]
      set s1x [lindex $bbox2_af_mg_pl 1]
      set s1y [lindex $bbox2_af_mg_pl 2]
      set distance_a [expr {sqrt ([expr {($mx - $s1x) * ($mx - $s1x)} + {($my - $s1y) * ($my - $s1y)}])}]
      puts "#######################################################################################"
      puts "Distance between the macro pin and the standard cell pin after magnet placement is $distance_a microns"
    } else {
      puts "No standard cell is connected to this macro pin. Begin again by selecting another macro pin"
    }
  } else {
    puts "No macro is selected or more than one macro is selected in GUI"
  }
}

define_proc_attributes magnet_place_dist -info "Finds the distance between a macro pin and a magnet standard cell pin before and after magnet placement."
