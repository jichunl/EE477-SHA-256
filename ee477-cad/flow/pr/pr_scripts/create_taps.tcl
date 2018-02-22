puts "PrimeRail-Info: Running script [info script]\n"

if { [llength $RAIL_TAP_LIB_CELLS] != 0 } {
  foreach lib_cell $RAIL_TAP_LIB_CELLS {
    create_taps -of_objects [get_lib_cells */$lib_cell]
  }
  unset lib_cell
}

redirect -tee -file $PR_REPORTS_DIR/check_taps.rpt {check_taps}
# redirect -tee -file $PR_REPORTS_DIR/report_taps.rpt {report_taps.rpt}

if { [llength $RAIL_SUPPLY_NETS] != 0 } {
  if { [llength $RAIL_SUPPLY_NETS] != [llength $RAIL_SUPPLY_VOLTAGE] } {
    echo "\n"
    echo "Error: The lengths of \$RAIL_SUPPLY_NETS and \$RAIL_SUPPLY_VOLTAGE do not match!"
  } else {
    set index 0
    foreach net $RAIL_SUPPLY_NETS {
      set_supply_voltage [lindex $RAIL_SUPPLY_VOLTAGE $index] -object_list $net
      incr index
    }
    unset net
    unset index
  }
}

if { [llength $RAIL_GROUND_NETS] != 0 } {
  if { [llength $RAIL_GROUND_NETS] != [llength $RAIL_GROUND_VOLTAGE] } {
    echo "\n"
    echo "Error: The lengths of \$RAIL_GROUND_NETS and \$RAIL_GROUND_VOLTAGE do not match!"
  } else {
    set index 0
    foreach net $RAIL_GROUND_NETS {
      set_supply_voltage [lindex $RAIL_GROUND_VOLTAGE $index] -object_list $net
      incr index
    }
    unset net
    unset index
  }
}


puts "PrimeRail-Info: Completed script [info script]\n"
