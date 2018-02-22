# Preroute commands, such as preroute_standard_cells and preroute_instances,
# issue the following warnings when they fail to connect any of the pins:
#
# WARNING:  Failed to make a connection for the following pin:
# ((565.995, 1847.765) (575.695, 1848.585)) (Net: VSS)(wire on layer: METAL2 [18])
# WARNING:  Failed to make a connection for the following pin:
# ((565.995, 1847.765) (575.695, 1848.585)) (Net: VSS)(wire on layer: METAL3 [22])
#
# The script helps you to directly zoom to the reported coordinates. You can
# then copy the coordinates and use them as the argument, as shown in the
# following examples.
#
# icc_shell> source zoom_to_failed_conn.tcl
#
# icc_shell> zoom_to_failed_conn {((565.995, 1847.765) (575.695, 1848.585))}

proc zoom_to_failed_conn { a } {

  set llx [lindex [split $a (,\ )] 2]
  set lly [lindex [split $a (,\ )] 4]
  set urx [lindex [split $a (,\ )] 7]
  set ury [lindex [split $a (,\ )] 9]

  gui_zoom -window [gui_get_current_window -view] -rect [list [list $llx $lly] [list $urx $ury]]
}
