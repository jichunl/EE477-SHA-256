# This script is to calculate the Manhattan or Euclidean distance between two
# centers of two cells.
#
# The following example shows how to report both the Manhattan and Euclidean
# distances between cell DXLC_5 and DXLC_6:
#
# icc_shell> cell_distance -euclidean 1 -manhattan 1 \
#                          -first_cell DXLC_5 \
#                          -second_cell DXLC_6
#
# The distance between the cells :
# 1.DXLC_5
# 2.DXLC_6
#
# Euclidean Distance : 984.457933564 microns
# Manhattan Distance : 1268.73 microns

proc get_center_coordinate {cell} {
  set bbox [get_attri [get_cell $cell] bbox]
  if { $bbox == "" } {
    puts "Warning : bbox for the cell $cell not defined"
  }
  set x1 [lindex [lindex $bbox 0] 0]
  set x2 [lindex [lindex $bbox 1] 0]
  set y1 [lindex [lindex $bbox 0] 1]
  set y2 [lindex [lindex $bbox 1] 1]
  set x [expr ($x1 + $x2)/2 ]
  set y [expr ($y1 + $y2)/2 ]
  return [list $x $y]
}

proc cell_distance { args } {
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

  if { [info exists results(-second_cell)] } {
    set second_cell $results(-second_cell)
  } else {
    set second_cell 0
    puts "Value of cell not entered"
  }

  if { [info exists results(-first_cell)] } {
    set first_cell $results(-first_cell)
  } else {
    set first_cell 0
    puts "Value of cell not entered"
  }

  foreach { cor1x cor1y } [get_center_coordinate $first_cell ] {}
  foreach { cor2x cor2y } [get_center_coordinate $second_cell ] {}

  puts "\nThe distance between the cells : \n1.$first_cell\n2.$second_cell\n"

  if { $euclidean == 1 } {
    set cor1 [expr { $cor2x - $cor1x }]
    set cor2 [expr { $cor2y - $cor1y }]
    set euc_dis [expr hypot ( $cor1 , $cor2 )]
    puts "Euclidean Distance : $euc_dis microns"
  } else {
    puts "Euclidean Distance : Not Calculated (For Euclidean distance between the cells make -euclidean 1)"
  }
  if { $manhattan == 1 } {
    set cor1 [expr { $cor2x - $cor1x } ]
    set cor2 [expr { $cor2y - $cor1y } ]
    set man_dis [expr { abs($cor2) + abs($cor1) }]
    puts "Manhattan Distance : $man_dis microns\n"
  } else {
    puts "Manhattan Distance : Not Calculated (For Manhattan distance between the cells make -manhattan 1)"
  }
}

define_proc_attributes cell_distance \
  -info "Find the Manhattan/Euclidean Distance between two sepcified cells" \
  -define_args {
    { -manhattan "Display the manhattan distance, default = 0 (Don't Display)" }
    { -euclidean "Display the euclidean distance, default = 0 (Don't Display)" }
    { -first_cell "Enter the cell name" }
    { -second_cell "Enter the cell name" }
  }
