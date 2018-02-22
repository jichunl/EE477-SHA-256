# This script is to calculate the Manhattan or Euclidean distance between two pins.
#
# The following example shows how to report the Manhattan distance between pins
# I_CLOCK_GEN/I_PLL_SD/REF_CLK and I_CLOCK_GEN/I_CLKMUL/CLK_2X:
#
# icc_shell> source pin_distance.tcl
#
# icc_shell> pin_distance -euclidean 1 -manhattan 0 \
#                         -first_pin I_CLOCK_GEN/I_PLL_SD/REF_CLK \
#                         -second_pin I_CLOCK_GEN/I_CLKMUL/CLK_2X
#
# The distance between the pins :
# 1.I_CLOCK_GEN/I_PLL_SD/REF_CLK
# 2.I_CLOCK_GEN/I_CLKMUL/CLK_2X
#
# Euclidean Distance : 527.291803938 microns
# Manhattan Distance : Not Calculated (For Manhattan distance between the pins make -manhattan 1)

proc get_center_coordinate {pin} {
  set bbox [get_attri [get_pins $pin] bbox]
  if { $bbox == "" } {
    puts "Warning : bbox for the pin $pin not defined"
  }
  set x1 [lindex [lindex $bbox 0] 0]
  set x2 [lindex [lindex $bbox 1] 0]
  set y1 [lindex [lindex $bbox 0] 1]
  set y2 [lindex [lindex $bbox 1] 1]
  set x [expr ($x1 + $x2)/2 ]
  set y [expr ($y1 + $y2)/2 ]
  return [list $x $y]
}

proc pin_distance { args } {
  parse_proc_arguments -args $args results

  if { [info exists results(-manhattan)] } {
     set manhattan $results(-manhattan)
  } else {
    set manhattan 0
  }
  if { [info exists results(-euclidean)] } {
     set euclidean $results(-euclidean)
  } else {
    set euclidean 0 
  }

  if { [info exists results(-second_pin)] } {
    set second_pin $results(-second_pin)
  } else {
    set second_pin 0
    puts "Value of cell not entered"
  }

  if { [info exists results(-first_pin)] } {
    set first_pin $results(-first_pin)
  } else {
    set first_pin 0
    puts "Value of cell not entered"
  }

  foreach { cor1x cor1y } [get_center_coordinate $first_pin ] {}
  foreach { cor2x cor2y } [get_center_coordinate $second_pin ] {}

  puts "\nThe distance between the pins : \n1.$first_pin\n2.$second_pin\n"

  if { $euclidean == 1 } {
    set cor1 [expr { $cor2x - $cor1x }]
    set cor2 [expr { $cor2y - $cor1y }]
    set euc_dis [expr hypot ( $cor1 , $cor2 )]
    puts "Euclidean Distance : $euc_dis microns"
  } else {
    puts "Euclidean Distance : Not Calculated (For Euclidean distance between the pins make -euclidean 1)"
  }
  if { $manhattan == 1 } {
    set cor1 [expr { $cor2x - $cor1x } ]
    set cor2 [expr { $cor2y - $cor1y } ]
    set man_dis [expr { abs($cor2) + abs($cor1) }]
    puts "Manhattan Distance : $man_dis microns\n"
  } else {
    puts "Manhattan Distance : Not Calculated (For Manhattan distance between the pins make -manhattan 1)"
  }
}

define_proc_attributes pin_distance \
  -info "Find the Manhattan/Euclidean Distance between two sepcified pins" \
  -define_args {
    { -manhattan "Display the manhattan distance, default = 0 (Don't Display)" }
    { -euclidean "Display the euclidean distance, default = 0 (Don't Display)" }
    { -first_pin "Enter the pin name" }
    { -second_pin "Enter the pin name" }
  }
