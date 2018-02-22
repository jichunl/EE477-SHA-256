# © 2014 Synopsys, Inc. All rights reserved. 
# # This script is proprietary and confidential information of 
# Synopsys, Inc. and may be used and disclosed only as authorized 
# per your agreement with Synopsys, Inc. controlling such use and disclosure.

#################################################
#Author Narendra Akilla
#Applications Consultant
#Company Synopsys Inc.
#Not for Distribution without Consent of Synopsys
#proc to report all the used lib cells in the design with dont_touch dont_use information
#################################################

proc proc_report_used_lib_cells {} {

  set cell_list [get_attr -quiet [get_cells -hi -filter "is_hierarchical==false"] ref_name]

  foreach cell $cell_list { if {[info exists ocnt($cell)]} { incr ocnt($cell) } else { set ocnt($cell) 1 } }

  foreach ref [array names ocnt] {
    set oref $ref
    if {[sizeof [get_lib_cell -quiet */$ref]]>0} {
      set lib_cell [index_collection [get_lib_cell */$ref] 0]
      if {[get_attr -quiet $lib_cell dont_use]=="true"} { set ref "$ref^" }
      if {[get_attr -quiet $lib_cell dont_touch]=="true"} { set ref "$ref~" }
    }
    set cnt($ref) $ocnt($oref)
  }

  set new ""
  foreach ref [array names cnt] { lappend new [list $ref $cnt($ref)] }

  set cnt_sorted [lsort -integer -decreasing -index 1 $new]
  set asc_sorted [lsort -dict -index 0 $new]

  puts "^ Indicates a dont_use on library cell"
  puts "~ Indicates a dont_touch on library cell"

  puts "------------------------------------------------------------------------------------"
  puts "           SORTED BY COUNT               ||            SORTED BY REF NAME"
  puts "-----------------------------------------||-----------------------------------------"
  #puts "                                         ||                                         "
  for {set i 0} {$i<[llength $cnt_sorted]} {incr i} {
    set tmp "[lindex $cnt_sorted $i] [lindex $asc_sorted $i]"
    puts "[format "%-30s-%7i   ||   %-30s-%7i" [lindex $tmp 0] [lindex $tmp 1] [lindex $tmp 2] [lindex $tmp 3]]"
  }
  puts "------------------------------------------------------------------------------------"

  puts "^ Indicates a dont_use on library cell"
  puts "~ Indicates a dont_touch on library cell"
  
}
#alias the same proc as proc_ref
interp alias {} proc_ref {} proc_report_used_lib_cells
echo "\tproc_report_used_lib_cells or proc_ref"
