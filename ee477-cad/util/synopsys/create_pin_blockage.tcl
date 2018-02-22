#------------------------------------------------------------------------------
# Adding Via Blockages to Prevent Undesired Pin Connections
#------------------------------------------------------------------------------
# 2014 Synopsys, Inc. All rights reserved.
#
# In emerging nodes, you need to extract the standard cell connectivity to
# ensure that the IC Compiler tool fully understands the interlayer design
# rules with the correct net interpretation.
#
# When connectivity extraction exposes pins that are not located on the topmost
# layer, you cannot guarantee that the router will not use those locations for
# pin connections.
#
# The create_pin_blockage.tcl script creates via blockages on the via1 layer to
# prevent the router from connecting to the metal1 layer when there is a metal2
# pin. The following example shows how to use this script:
#
# icc_shell> source ./create_pin_blockage.tcl
# icc_shell> create_pin_blockage -help
# icc_shell> create_pin_blockage -lib libToRun -upper_metal metal2 -lower_metal metal1 -blockage via1Blockage
#------------------------------------------------------------------------------

proc create_pin_blockage { args } {

  parse_proc_arguments -args $args res

  set libName $res(-lib)
  set Upper_layer $res(-upper_metal)
  set Lower_layer $res(-lower_metal)
  set Blockage $res(-blockage)

  suppress_message "SEL-004 MWUI-068 IFS-008"

  open_mw_lib $libName
  foreach_in_collection libCell [get_mw_cels *.FRAM] {
    set cellName [get_attr $libCell full_name]
    open_mw_cel ${cellName}
    if { [sizeof_collection [get_terminals -filter "layer==$Upper_layer"] ] > 0 } {
      foreach_in_collection M2_pin [get_terminals -filter "layer==$Upper_layer"] {
        set M2_pin_name [get_att [get_terminals $M2_pin] name]
        foreach_in_collection M1_pin [get_terminals -filter "layer==$Lower_layer&&owner_port==$M2_pin_name" ] {
        set M1_object [get_attr [get_terminals $M1_pin] object_id]
          set shape_location [get_attr [get_terminals -filter "object_id==$M1_object"] points]
          set total_points [llength $shape_location]
          set i 0
          while {$i < $total_points} {
            set RG_llx [expr [lindex [lindex $shape_location $i] 0] ]
            set RG_lly [lindex [lindex $shape_location $i] 1]
            set RG_urx [expr [lindex [lindex $shape_location [expr $i + 2] ] 0] ]
            set RG_ury [lindex [lindex $shape_location [expr $i + 2] ] 1]
            create_routing_blockage -bbox "$RG_llx $RG_lly $RG_urx $RG_ury" -layers $Blockage
            set i [expr $i + 5]
          }
        }
      }
      save_mw_cel
    }
    close_mw_cel
  }
  close_mw_lib
}

define_proc_attributes create_pin_blockage \
  -info "Create via blockage for pin region below topmost metal layer" \
  -define_args {
    { -lib         "Standard cell library path" }
    { -upper_metal "Upper metal layer of a pin" }
    { -lower_metal "Lower metal layer of a pin" }
    { -blockage    "Via blockage layer"         }
}
