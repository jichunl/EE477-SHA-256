#-----------------------------------------------------------------------------
#  University of California, San Diego
#-----------------------------------------------------------------------------
#  get_feature_nets.tcl
#
#  Purpose: Grab nets with specific features for further inspections, for
#           example clock nets or high capacitive nets.
#
#-----------------------------------------------------------------------------

proc get_feature_nets {args} {

  parse_proc_arguments -args $args pargs

  set feature_nets []

  # User specifies clock nets to be collected.
  if {[info exists pargs(-clock)]} {
    puts "Getting all clock nets in design:"
    set feature_nets [get_nets -all -hierarchical -top_net_of_hierarchical_group -filter "net_type=~Clock"]
  }

  # Get output file
  if {[info exists pargs(-output)]} {
    set output_file_name $pargs(-output)
    set output_file      [open $output_file_name "w"]

    if {[sizeof_collection $feature_nets] != 0} {
      puts $output_file [join [get_attribute $feature_nets full_name] \n]
    } else {
      puts $output_file "The collection is empty for specified feature nets."
    }

    close $output_file
  }
}

define_proc_attributes get_feature_nets  \
  -info "get_feature_nets - get nets with specific features for further inspections." \
  -define_args {
    {-clock "get all clock nets" "" boolean optional}
    {-output "output file name" "filename" string optional}
  }
