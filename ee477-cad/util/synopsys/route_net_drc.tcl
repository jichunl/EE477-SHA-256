################################################################################
# 2013 Synopsys, Inc.  All rights reserved.
#
# This script is proprietary and confidential information of Synopsys, Inc. and
# may be used and disclosed only as authorized per your agreement with
# Synopsys, Inc. controlling such use and disclosure.
#
# File:    route_net_drc.tcl
#
# Purpose: This procedure returns if given net has any DRC violation.
#
# Usage: icc_shell> verify_zrt_route
#        icc_shell> source route_net_drc.tcl
#        icc_shell> route_net_drc -net <net_name>
#
# Example Output:
#        icc_shell> route_net_drc -net I_BLENDER_1/mult_170/n554
#                   Given net is I_BLENDER_1/mult_170/n554
#                   I_BLENDER_1/mult_170/n554 has a Short DRC violation
################################################################################

proc route_net_drc {args} {
  parse_proc_arguments -args $args results
  set my_net $results(-net)
  echo "Given net is $my_net"

  foreach drctype [list_drc_error_type] {
    set drc_nets [get_attribute -class drc_error [get_drc_errors -type $drctype] nets]

    set unique_drc_nets ""
    foreach_in_collection i $drc_nets {
      append_to_collection -unique unique_drc_nets [get_nets $i]
    }

    set intersect_net [remove_from_collection [get_flat_nets $unique_drc_nets] \
                      [remove_from_collection [get_flat_nets  $unique_drc_nets] \
                      [get_flat_nets $my_net]]]
    set count [sizeof_col $intersect_net]
    if {$count == 1} {
      echo "$my_net has a $drctype DRC violation"
      change_selection [get_nets $my_net]
    }
  }
}

define_proc_attributes route_net_drc \
  -info "DRC type of a given net" \
  -define_args {
     {-net "Net Name" net string required}
  }
